use chrono::Local;
use clap::{CommandFactory, Parser, ValueEnum};
use clap_complete::generator::generate;
use clap_complete::Shell;
use script_helpers::{back_up_existing_file, sha256_hash_file_to_string};
use shell_quote::{Bash, QuoteRefExt};
use std::fs::read_to_string;
use std::fs::OpenOptions;
use std::io::stdout;
use std::io::BufRead;
use std::io::Write;
use std::path::Path;
use std::path::PathBuf;
use std::process::{exit, Command};

const BIN_NAME: &str = "openscad-auto"; // TODO: get this from `clap`

const DEFAULT_VARIANT: &str = "default";

// TODO: why does a program description alter the way individual flag help is printed??
/// `openscad-auto`` converts files using the `openscad` CLI, with some
/// conveniences.
///
/// - Multiple variants can be specified in the source file, and `openscad-auto`
///   will render each variant by setting the `VARIANT` variable.
///   - Variants are specified by a JSON object between a `START_AUTO_INCLUDED_VARIANTS` line and `END_AUTO_INCLUDED_VARIANTS` line.
/// - The `lazy-union` feature and `manifold` backend are used.
/// - Upon rendering, the program can:
///   - Reveal the output file(s) (default)
///   - Show a notification (opt-in)
#[derive(Parser, Debug)]
#[clap(version, verbatim_doc_comment)]
struct Args {
    // Source OpenSCAD file.
    #[clap(group = "task")]
    source: Option<PathBuf>,

    /// The generated output format.
    #[clap(long, default_value = "3mf")]
    format: OutputFormat,

    /// Print completions for the given shell (instead of running the command normally).
    /// These can be loaded/stored permanently (e.g. when using Homebrew), but they can also be sourced directly, e.g.:
    ///
    ///  openscad-auto --completions fish | source # fish
    ///  source <(openscad-auto --completions zsh) # zsh
    #[clap(long, group = "task", id = "SHELL")]
    completions: Option<Shell>,

    /// Notify upon completion using `terminal-notifier` (macOS)
    #[clap(long)]
    notify: bool,

    /// Do not reveal the generated output file(s) upon completions.
    #[clap(long)]
    no_reveal: bool,

    /// A comma-separated list of variants.
    /// Example: `--variants small,small-unengraved,large`
    #[clap(long, value_delimiter = ',')]
    variants: Vec<String>,
}

#[derive(Clone, Debug, ValueEnum)]
#[allow(non_camel_case_types)]
enum OutputFormat {
    #[clap(name = "stl")]
    stl,
    #[clap(name = "3mf")]
    _3mf,
}

impl OutputFormat {
    fn file_extension(&self) -> &str {
        match self {
            OutputFormat::stl => "stl",
            OutputFormat::_3mf => "3mf",
        }
    }
}

fn get_args() -> Args {
    // TODO: use the new `clap` built-in functionality.
    let mut command = Args::command();

    let args = Args::parse();
    if let Some(shell) = args.completions {
        generate(shell, &mut command, BIN_NAME, &mut stdout());
        exit(0);
    };

    args
}

const START_AUTO_INCLUDED_VARIANTS: &str = "START_AUTO_INCLUDED_VARIANTS";
const END_AUTO_INCLUDED_VARIANTS: &str = "END_AUTO_INCLUDED_VARIANTS";

// TODO: read variants from the `VARIANT` variable assignment once I'm using a formatter that doesn't break this.
fn variants_from_file(file: &PathBuf) -> Option<Vec<Option<String>>> {
    let contents = read_to_string(file).expect("Could not find source file.");
    // TODO: turn this into a reader?
    let mut json_lines: Vec<&str> = vec![];

    let mut in_range = false;
    for line in contents.lines() {
        if line == START_AUTO_INCLUDED_VARIANTS {
            in_range = true;
            continue;
        }
        if line == END_AUTO_INCLUDED_VARIANTS {
            break;
        }
        if in_range {
            json_lines.push(line);
        }
    }
    if !in_range {
        return None;
    }
    let json = json_lines.join("\n");
    let variants: Vec<Option<String>> =
        serde_json::from_str(&json).expect("Invalid listing of variants.");
    Some(variants)
}

fn main() {
    let args = get_args();
    let Some(source_file) = args.source else {
        Args::command().print_help().unwrap();
        exit(1);
    };

    // We parse this unconditionally, so that passing `--variants` doesn't mask a syntax error.
    let variants = variants_from_file(&source_file);

    let variants: Vec<Option<String>> = match args.variants.len() {
        0 => variants.unwrap_or(vec![None]),
        _ => args.variants.into_iter().map(Some).collect(),
    };

    println!(
        "Rendering variants:

{}
",
        variants
            .iter()
            .map(|v| format!("- {}", v.clone().unwrap_or("(default)".to_owned())))
            .collect::<Vec<String>>()
            .join("\n")
    );

    let sha256_hash = sha256_hash_file_to_string(&source_file);

    let mut files_to_reveal: Vec<String> = vec![];

    for variant in variants {
        let variant_suffix = match &variant {
            Some(variant) => format!(".{}", variant),
            None => "".to_owned(),
        };
        let target_file_string = format!(
            "{}{}.{}",
            source_file.to_string_lossy(),
            variant_suffix,
            args.format.file_extension(),
        );
        let target_file = Path::new(&target_file_string);

        back_up_existing_file(target_file, args.format.file_extension());

        println!("✍️ Writing new file to: {}", target_file.to_string_lossy());

        let output = Command::new("/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD")
            .args([
                "--enable",
                "lazy-union",
                "--backend",
                "Manifold",
                "-D",
                // TODO: what are OpenSCAD's escaping rules?
                &format!(
                    "VARIANT = {:?};",
                    variant.unwrap_or(DEFAULT_VARIANT.to_owned())
                ),
                "-o",
                &target_file.to_string_lossy(),
                &source_file.to_string_lossy(),
            ])
            .env("FONTCONFIG_PATH", "/opt/homebrew/etc/fonts")
            .output()
            .expect("Could not invoke `openscad`.");

        let mut total_rendering_time_string = Option::<String>::default();
        for line in output.stderr.lines().map_while(Result::ok) {
            eprintln!("{}", line);
            if line.starts_with("Total rendering time") {
                total_rendering_time_string = Some(
                    line.splitn(2, ": ")
                        .last()
                        .expect("Could not determine total rendering time from output")
                        .to_owned(),
                );
            }
        }
        let Some(total_rendering_time_string) = total_rendering_time_string else {
            exit(1);
        };

        let mut file = OpenOptions::new()
            .append(true)
            .open(target_file)
            .expect("Could not access target file to add rendering comments.");

        // TODO: properly add this via 3MF metadata. In theory text comments are not part of the `.3mf` format, but they don't seem to mess anything up?
        writeln!(
            file,
            "\n/* Generated by `openscad-auto` on {} in {} from: {} (sha256: {}) */",
            Local::now().format("%Y-%m-%d"),
            total_rendering_time_string,
            source_file.to_string_lossy(),
            sha256_hash
        )
        .expect("Could not write comment to target file.");

        let quoted_target_file: String = (target_file.to_string_lossy()).quoted(Bash);
        // TODO: notify only once for all variants?
        if args.notify {
            Command::new("terminal-notifier")
                .args(vec![
                    "-title",
                    "openscad-auto",
                    "-message",
                    &format!(
                        "⏭️ Done converting: {}
⏱️ Total rendering time: {}",
                        source_file.to_string_lossy(),
                        total_rendering_time_string
                    ),
                    "-execute",
                    &format!("open -R {}", quoted_target_file),
                ])
                .spawn()
                .unwrap()
                .wait()
                .unwrap();
        }

        files_to_reveal.push(target_file.to_string_lossy().to_string());
    }
    if !args.no_reveal {
        Command::new("reveal-macos")
            .args(files_to_reveal)
            .spawn()
            .unwrap()
            .wait()
            .unwrap();
    }
}

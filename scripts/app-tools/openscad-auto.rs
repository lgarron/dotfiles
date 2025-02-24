use chrono::Local;
use clap::{CommandFactory, Parser, ValueEnum};
use clap_complete::generator::generate;
use clap_complete::Shell;
use script_helpers::{back_up_existing_file, sha256_hash_file_to_string};
use shell_quote::{Bash, QuoteRefExt};
use std::fs::OpenOptions;
use std::io::stdout;
use std::io::BufRead;
use std::io::Write;
use std::path::Path;
use std::path::PathBuf;
use std::process::{exit, Command};

const BIN_NAME: &str = "openscad-auto"; // TODO: get this from `clap`

#[derive(Parser, Debug)]
#[clap(version)]
struct Args {
    #[clap(verbatim_doc_comment, group = "task")]
    source: Option<PathBuf>,

    #[clap(long, default_value = "3mf")]
    format: OutputFormat,

    #[clap(long, group = "task", id = "SHELL")]
    completions: Option<Shell>,

    #[clap(long)]
    notify: bool,

    #[clap(long)]
    no_reveal: bool,
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

fn main() {
    let args = get_args();
    let Some(source_file) = args.source else {
        Args::command().print_help().unwrap();
        exit(1);
    };

    let sha256_hash = sha256_hash_file_to_string(&source_file);

    let target_file_string = format!(
        "{}.{}",
        source_file.to_string_lossy(),
        args.format.file_extension()
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

    if !args.no_reveal {
        Command::new("open")
            .args(vec!["-R", &target_file.to_string_lossy()])
            .spawn()
            .unwrap()
            .wait()
            .unwrap();
    }
}

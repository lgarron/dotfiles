interface JSONShape {
  "left-ribbon"?: { hiddenItems: Record<string, boolean> };
}

export function cleanWorkspaceJSON(json: JSONShape): JSONShape {
  // Record hidden items.
  const { "left-ribbon": leftRibbon } = json;
  return { "left-ribbon": leftRibbon };
}

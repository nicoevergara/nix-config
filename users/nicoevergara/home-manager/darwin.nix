let
  rootPath = ../../..;
in
{
  targets.darwin.linkApps.enable = true;
  targets.darwin.copyApps.enable = false;

  home.file.".cursor/AGENTS.md".source = "${rootPath}/modules/llms/AGENTS.md";
}

{
  username,
  ...
}:
{
  system.activationScripts.extraActivation.text = ''
    echo "Checking for ~/Projects directory..."
    mkdir -p "/Users/${username}/Projects"
    chown ${username}:staff "/Users/${username}/Projects"
  '';
}

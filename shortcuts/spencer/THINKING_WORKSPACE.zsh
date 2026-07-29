open -a Spencer
for i in {1..20}; do
  if /Applications/Spencer.app/Contents/MacOS/SpencerCLI --list >/dev/null 2>&1; then
    /Applications/Spencer.app/Contents/MacOS/SpencerCLI --restore "THINKING_WORKSPACE" --launch-apps=true
    exit $?
  fi
  sleep 0.5
done
echo "Spencer CLI did not become ready" >&2
exit 1


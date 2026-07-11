-- applescript/project-selector.applescript
-- Simple project picker over configured projects_root

on run
  set projectRoot to "/Users/eduardofgiovannini/Documents/GitHub"
  set openInCursor to false

  try
    set projectRoot to do shell script "zsh -c 'source \"${HOME}/Documents/GitHub/ipad-stream-deck-console/scripts/lib/common.zsh\" 2>/dev/null; sd_json_get \"${HOME}/Documents/GitHub/ipad-stream-deck-console/config/paths.json\" projects_root'"
  end try

  set projectDirs to my listProjectDirs(projectRoot)
  if (count of projectDirs) is 0 then
    display dialog "No projects found in:" & return & projectRoot buttons {"OK"} default button "OK" with title "Project Selector"
    return
  end if

  set chosenProject to choose from list projectDirs with prompt "Select a project:" OK button name "Open in Finder" cancel button name "Cancel"
  if chosenProject is false then return

  set selectedName to item 1 of chosenProject
  set selectedPath to projectRoot & "/" & selectedName

  set openChoice to button returned of (display alert "Open project" message selectedName buttons {"Finder", "Cursor", "Cancel"} default button "Finder" cancel button "Cancel")
  if openChoice is "Cancel" then return

  if openChoice is "Cursor" then
    do shell script "open -a Cursor " & quoted form of selectedPath
  else
    do shell script "open " & quoted form of selectedPath
  end if
end run

on listProjectDirs(rootPath)
  set projectDirs to {}
  try
    set rawList to do shell script "find " & quoted form of rootPath & " -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sort"
    set AppleScript's text item delimiters to linefeed
    set dirPaths to text items of rawList
    set AppleScript's text item delimiters to ""

    repeat with dirPath in dirPaths
      if dirPath is not "" then
        set dirName to do shell script "basename " & quoted form of dirPath
        set end of projectDirs to dirName
      end if
    end repeat
  end try
  return projectDirs
end listProjectDirs

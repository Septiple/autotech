Foreach ($file in Get-ChildItem ".\unfiltered_input") {
    Write-Output "Reading $file.name"

    $JsonFile = Get-Content ".\unfiltered_input\$($file.name)" -raw | ConvertFrom-Json
    Write-Output "Done reading"

    $JsonFile.PSObject.Properties.Remove("achievement")
    $JsonFile.PSObject.Properties.Remove("ambient-sound")
    $JsonFile.PSObject.Properties.Remove("blueprint-book")
    $JsonFile.PSObject.Properties.Remove("blueprint")
    $JsonFile.PSObject.Properties.Remove("build-entity-achievement")
    $JsonFile.PSObject.Properties.Remove("combat-robot-count")
    $JsonFile.PSObject.Properties.Remove("construct-with-robots-achievement")
    $JsonFile.PSObject.Properties.Remove("copy-paste-tool")
    $JsonFile.PSObject.Properties.Remove("custom-input")
    $JsonFile.PSObject.Properties.Remove("deconstruct-with-robots-achievement")
    $JsonFile.PSObject.Properties.Remove("deconstruction-item")
    $JsonFile.PSObject.Properties.Remove("deliver-by-robots-achievement")
    $JsonFile.PSObject.Properties.Remove("dont-build-entity-achievement")
    $JsonFile.PSObject.Properties.Remove("dont-craft-manually-achievement")
    $JsonFile.PSObject.Properties.Remove("dont-use-entity-in-energy-production-achievement")
    $JsonFile.PSObject.Properties.Remove("editor-controller")
    $JsonFile.PSObject.Properties.Remove("finish-the-game-achievement")
    $JsonFile.PSObject.Properties.Remove("font")
    $JsonFile.PSObject.Properties.Remove("god-controller")
    $JsonFile.PSObject.Properties.Remove("group-attack-achievement")
    $JsonFile.PSObject.Properties.Remove("gui-style")
    $JsonFile.PSObject.Properties.Remove("kill-achievement")
    $JsonFile.PSObject.Properties.Remove("logistic-network-embargo")
    $JsonFile.PSObject.Properties.Remove("map-gen-presets")
    $JsonFile.PSObject.Properties.Remove("map-settings")
    $JsonFile.PSObject.Properties.Remove("mouse-cursor")
    $JsonFile.PSObject.Properties.Remove("noise-expression")
    $JsonFile.PSObject.Properties.Remove("noise-layer")
    $JsonFile.PSObject.Properties.Remove("optimized-decorative")
    $JsonFile.PSObject.Properties.Remove("optimized-particle")
    $JsonFile.PSObject.Properties.Remove("player-damaged-achievement")
    $JsonFile.PSObject.Properties.Remove("produce-achievement")
    $JsonFile.PSObject.Properties.Remove("produce-per-hour-achievement")
    $JsonFile.PSObject.Properties.Remove("research-achievement")
    $JsonFile.PSObject.Properties.Remove("selection-tool")
    $JsonFile.PSObject.Properties.Remove("shortcut")
    $JsonFile.PSObject.Properties.Remove("spectator-controller")
    $JsonFile.PSObject.Properties.Remove("sprite")
    $JsonFile.PSObject.Properties.Remove("tile-effect")
    $JsonFile.PSObject.Properties.Remove("tips-and-tricks-item-category")
    $JsonFile.PSObject.Properties.Remove("tips-and-tricks-item")
    $JsonFile.PSObject.Properties.Remove("train-path-achievement")
    $JsonFile.PSObject.Properties.Remove("trigger-target-type")
    $JsonFile.PSObject.Properties.Remove("trivial-smoke")
    $JsonFile.PSObject.Properties.Remove("tutorial")
    $JsonFile.PSObject.Properties.Remove("upgrade-item")
    $JsonFile.PSObject.Properties.Remove("utility-constants")
    $JsonFile.PSObject.Properties.Remove("utility-sounds")
    $JsonFile.PSObject.Properties.Remove("utility-sprites")
    $JsonFile.PSObject.Properties.Remove("virtual-signal")
    $JsonFile.PSObject.Properties.Remove("wind-sound")
    
    # 2.0 prototypes
    $JsonFile.PSObject.Properties.Remove("airborne-pollutant")
    $JsonFile.PSObject.Properties.Remove("burner-usage")
    $JsonFile.PSObject.Properties.Remove("chain-active-trigger")
    $JsonFile.PSObject.Properties.Remove("change-surface-achievement")
    $JsonFile.PSObject.Properties.Remove("complete-objective-achievement")
    $JsonFile.PSObject.Properties.Remove("create-platform-achievement")
    $JsonFile.PSObject.Properties.Remove("custom-event")
    $JsonFile.PSObject.Properties.Remove("delayed-active-trigger")
    $JsonFile.PSObject.Properties.Remove("deliver-by-robots-achievement")
    $JsonFile.PSObject.Properties.Remove("deplete-resource-achievement")
    $JsonFile.PSObject.Properties.Remove("destroy-cliff-achievement")
    $JsonFile.PSObject.Properties.Remove("dont-kill-manually-achievement")
    $JsonFile.PSObject.Properties.Remove("dont-research-before-researching-achievement")
    $JsonFile.PSObject.Properties.Remove("dont-use-entity-in-energy-production-achievement")
    $JsonFile.PSObject.Properties.Remove("equip-armor-achievement")
    $JsonFile.PSObject.Properties.Remove("module-transfer-achievement")
    $JsonFile.PSObject.Properties.Remove("noise-function")
    $JsonFile.PSObject.Properties.Remove("place-equipment-achievement")
    $JsonFile.PSObject.Properties.Remove("procession-layer-inheritance-group")
    $JsonFile.PSObject.Properties.Remove("procession")
    $JsonFile.PSObject.Properties.Remove("remote-controller")
    $JsonFile.PSObject.Properties.Remove("research-with-science-pack-achievement")
    $JsonFile.PSObject.Properties.Remove("shoot-achievement")
    $JsonFile.PSObject.Properties.Remove("space-connection-distance-traveled-achievement")
    $JsonFile.PSObject.Properties.Remove("use-item-achievement")

    Write-Output "Done filtering"

    $JsonFile | ConvertTo-Json -Compress -Depth 100 | Set-Content ".\filtered_input\$($file.name)"
    Write-Output "Done writing"
}

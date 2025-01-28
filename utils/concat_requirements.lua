local function concat_requirements(requirements)
    local dependency_names = ""
    for requirement_name, _ in pairs(requirements) do
        dependency_names = dependency_names .. requirement_name .. ", "
    end
    -- trim last ", "
    if dependency_names:sub(-2) == ", " then
        dependency_names = dependency_names:sub(1, -3)
    end

    return dependency_names
end

return concat_requirements
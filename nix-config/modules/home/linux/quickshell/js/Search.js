.pragma library

function filterTargets(targets, query) {
    var normalized = query.trim().toLowerCase()
    var commandOnly = normalized.charAt(0) === ">"
    if (commandOnly)
        normalized = normalized.slice(1).trim()
    if (normalized.length === 0)
        return commandOnly ? targets.filter(function(target) { return target.kind === "COMMAND" }) : targets
    return targets.filter(function(target) {
        if (commandOnly && target.kind !== "COMMAND")
            return false
        return (target.label + " " + target.detail + " " + (target.kind || "")).toLowerCase().indexOf(normalized) !== -1
    })
}

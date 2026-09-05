.pragma library

function cpuSample(text) {
    var line = text.split("\n")[0]
    var fields = line.trim().split(/\s+/)
    if (fields.length < 8 || fields[0] !== "cpu")
        return null

    var total = 0
    for (var index = 1; index < fields.length; index++)
        total += Number(fields[index])

    return {
        total: total,
        idle: Number(fields[4]) + Number(fields[5])
    }
}
function cpuPercent(previous, current) {
    if (!previous || !current)
        return null
    var totalDelta = current.total - previous.total
    var idleDelta = current.idle - previous.idle
    if (totalDelta <= 0)
        return null
    return Math.max(0, Math.min(100, 100 * (totalDelta - idleDelta) / totalDelta))
}

function memoryPercent(text) {
    var total = 0
    var available = 0
    var lines = text.split("\n")
    for (var index = 0; index < lines.length; index++) {
        var parts = lines[index].trim().split(/\s+/)
        if (parts[0] === "MemTotal:")
            total = Number(parts[1])
        else if (parts[0] === "MemAvailable:")
            available = Number(parts[1])
    }
    if (total <= 0 || available < 0)
        return null
    return Math.max(0, Math.min(100, 100 * (total - available) / total))
}

function firstTemperature(value) {
    if (value === null || value === undefined)
        return null
    if (typeof value === "number")
        return null
    if (Array.isArray(value)) {
        for (var index = 0; index < value.length; index++) {
            var arrayResult = firstTemperature(value[index])
            if (arrayResult !== null)
                return arrayResult
        }
        return null
    }
    if (typeof value === "object") {
        var keys = Object.keys(value)
        for (var keyIndex = 0; keyIndex < keys.length; keyIndex++) {
            var key = keys[keyIndex]
            if (/_input$/.test(key) && typeof value[key] === "number"
                    && value[key] > -40 && value[key] < 160)
                return value[key]
            var objectResult = firstTemperature(value[key])
            if (objectResult !== null)
                return objectResult
        }
    }
    return null
}

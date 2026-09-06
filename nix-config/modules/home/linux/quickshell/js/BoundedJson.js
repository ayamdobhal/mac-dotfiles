.pragma library

function parse(text, maximumBytes) {
    if (typeof text !== "string")
        return { ok: false, error: "NON_TEXT_PAYLOAD", value: null }
    if (text.length === 0)
        return { ok: false, error: "EMPTY_PAYLOAD", value: null }
    if (text.length > maximumBytes)
        return { ok: false, error: "PAYLOAD_LIMIT", value: null }

    try {
        return { ok: true, error: "", value: JSON.parse(text) }
    } catch (error) {
        return { ok: false, error: "INVALID_JSON", value: null }
    }
}

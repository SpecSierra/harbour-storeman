.pragma library

// Font Awesome Free (solid) glyphs of the subcategories at OpenRepos.net, by category identifier.
// The main categories have Silica theme icons instead. The code points are those of
// fonts/fa-solid-900.ttf.
var glyphs = {
    257: "\uf3cf", // Application: mobile-screen
    4206: "\uf05e", // Adult Content: ban
    1845: "\uf53f", // Ambience & Themes: palette
    2: "\uf0b1", // Business: briefcase
    3: "\uf5a0", // City guides & maps: map-location-dot
    1324: "\uf0c3", // Education & Science: flask
    4: "\uf630", // Entertainment: masks-theater
    5: "\uf001", // Music: music
    8: "\uf6ff", // Network: network-wired
    6: "\uf1ea", // News & info: newspaper
    2983: "\uf462", // Patches: bandage
    7: "\uf030", // Photo & video: camera
    3755: "\uf207", // Public Transport: bus
    9: "\uf0c0", // Social Networks: users
    10: "\uf70c", // Sports: person-running
    147: "\uf2db", // System: microchip
    250: "\uf059", // Unknown: circle-question
    11: "\uf7d9", // Utilities: screwdriver-wrench
    256: "\uf11b", // Game: gamepad
    13: "\uf0e7", // Action: bolt
    14: "\uf14e", // Adventure: compass
    15: "\uf6e2", // Arcade: ghost
    16: "\uf522", // Card & casino: dice
    17: "\uf19d", // Education: graduation-cap
    18: "\uf12e", // Puzzle: puzzle-piece
    19: "\uf1e3", // Sports: futbol
    20: "\uf439", // Strategy: chess
    21: "\uf0eb" // Trivia: lightbulb
}

// The entry of a category that lists the applications of all its subcategories
var all = "\uf03a"

// A subcategory that has no glyph of its own, for example a new one
var fallback = "\uf07b"

function glyph(categoryId) {
    return glyphs[categoryId] || fallback
}

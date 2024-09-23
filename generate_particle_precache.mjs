import * as fs from "fs";
import * as path from "path";

const regex = /"[\w_/-]+?\.vpcf"/g;

const precacheList = [];

function processFile(path) {
    const file = fs.readFileSync(path, "utf8");
    
    precacheList.push(...(file.match(regex) ?? []));
}

function processFolder(ext, ...pathFragments) {
    const base = path.join(...pathFragments);
    const entries = fs.readdirSync(base, { recursive: true });

    for (const entry of entries) {
        if (entry.endsWith(ext)) {
            const fullPath = path.join(...pathFragments, entry);
            processFile(fullPath);
        }
    }
}

processFolder(".lua", "game", "scripts");
processFolder(".js", "content", "panorama", "scripts");

const deduplicated = [...new Set(precacheList).values()].sort();

fs.writeFileSync("game/scripts/vscripts/particles.lua", `return { \n    ${deduplicated.join(",\n    ")}\n}`)

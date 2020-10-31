const fs = require("fs");
const path = require("path");

const base = "content/panorama/images/custom_game";
const all_files = [];

function read_dir(dir) {
    const contents = fs.readdirSync(dir);

    for (const name of contents) {
        const full_path = `${dir}/${name}`;
        const stat = fs.statSync(full_path);

        if (stat.isDirectory()) {
            read_dir(full_path);
        } else {
            all_files.push(path.posix.relative(base, full_path));
        }
    }
}

read_dir(base);

console.log(
    all_files
        .filter(file => file.endsWith(".jpg") || file.endsWith(".png"))
        .map(file => `background-image: url("file://{images}/custom_game/${file}");`)
        .join("\n")
);
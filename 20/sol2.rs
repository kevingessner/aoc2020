use std::io::{self, BufRead};
use std::vec::Vec;
use std::collections::{HashSet, HashMap};
use std::fmt;
use regex::Regex;


#[derive(Debug, Clone)]
struct RawTile {
    id: String,
    lines: Vec<String>,
}

impl Default for RawTile {
    fn default() -> Self { RawTile{
        id: "".to_string(),
        lines: Vec::<String>::new(),
    } }
}

#[derive(Debug, Copy, Clone, Eq, Hash, PartialEq)]
struct TileId {
    num: u16, // tile number
    dir: u8, // rotation/flip direction, 0-7
}

impl fmt::Display for TileId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}/{}", self.num, self.dir)
    }
}


// A tile, rotated/flipped. The top/right/bottom/left read 'naturally' (i.e. left and right from
// top to bottom, top and bottom from left to right) for the applied transformation.
struct Tile {
    id: TileId,
    top: String,
    left: String,
    bottom: String,
    right: String,
    // tiles that match immediately to the right of this one
    to_rights: HashSet<TileId>,
    // tiles that match immediately to the bottom of this one
    to_bottoms: HashSet<TileId>,
    inner_lines: Vec<String>,
}

impl PartialEq for Tile {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

fn ids_to_grid<'a>(ids: &Vec<TileId>, sq: usize) -> String {
    ids.chunks(sq)
        .map(|row| row.iter().fold(String::new(), |acc, arg| acc + " " + &arg.to_string()))
        .fold(String::new(), |acc, arg| acc + "\n" + &arg)
}

fn ids_to_inner(tiles: &HashMap<TileId, Tile>, ids: &Vec<TileId>, sq: usize) -> String {
    ids.chunks(sq)
        .map(|row_ids| {
            let tiles = row_ids.iter().map(|id| tiles.get(id).unwrap()).collect::<Vec<_>>();
            let mut row_str = "".to_string();
            for i in 0..8 {
                row_str = format!("{}{}\n", row_str, tiles
                    .iter()
                    .map(|tile| tile.inner_lines.get(i).unwrap().to_string())
                    .collect::<Vec<String>>()
                    .as_slice()
                    .join("")
                    .to_string())
            }
            row_str
        })
        .collect::<Vec<String>>()
        .as_slice()
        .join("")
}

// Recursively finds solutions where an unused tile that matches to the right/bottom of existing
// tiles can be assigned to the next free spot.
fn allowed<'a>(all_tiles: &HashMap<TileId, Tile>, unused_tile_nums: &HashSet<u16>, sq: usize, assigned: &Vec<TileId>, match_right_of: Option<TileId>, match_bottom_of: Option<TileId>) -> Vec<Vec<TileId>> {
    //println!("checking {} {:?} -> ({:?}, {:?})", sq, assigned, match_right_of, match_bottom_of);
    let allowed = match (match_right_of, match_bottom_of) {
        (Some(right), Some(bottom)) => all_tiles[&right].to_rights.intersection(&all_tiles[&bottom].to_bottoms).collect::<Vec<&TileId>>(),
        (None, Some(bottom)) => all_tiles[&bottom].to_bottoms.iter().collect::<Vec<&TileId>>(),
        (Some(right), None) => all_tiles[&right].to_rights.iter().collect::<Vec<&TileId>>(),
        (None, None) => vec![],
    };
    return allowed.iter()
        .filter(|id| unused_tile_nums.contains(&id.num))
        .map(|id| {
            let mut newunused = unused_tile_nums.clone();
            newunused.remove(&id.num);
            let mut newassigned = assigned.clone();
            newassigned.push(**id);
            //println!("proceeding ({:?}, {:?}) -> {:?}", match_right_of, match_bottom_of, newassigned);
            attempt(all_tiles, &newunused, sq, &newassigned)
        })
        .flatten()
        .collect::<Vec<Vec<TileId>>>();
}

// Recursivelt finds solutions by filling the grid by row from top left, checking the adjacent
// tiles at each new assignment.
fn attempt<'a>(all_tiles: &HashMap<TileId, Tile>, unused_tile_nums: &HashSet<u16>, sq: usize, assigned: &Vec<TileId>) -> Vec<Vec<TileId>> {
    let u = assigned.len();

    // All done!
    if 0 == unused_tile_nums.len() {
        return vec![assigned.to_vec()];
    }

    // first row -> check the previous tile
    if u < sq {
        return allowed(all_tiles, unused_tile_nums, sq, assigned, Some(assigned[u-1]), None)
    }
    // first column -> check the above tile
    if u % sq == 0 {
        return allowed(all_tiles, unused_tile_nums, sq, assigned, None, Some(assigned[u - sq]));
    }
    return allowed(all_tiles, unused_tile_nums, sq, assigned, Some(assigned[u - 1]), Some(assigned[u - sq]));
}

fn main() {
    let mut rawtiles = Vec::<RawTile>::new();
    let stdin = io::stdin();
    let mut i = 0;
    let mut tile: RawTile = Default::default();
    for line in stdin.lock().lines() {
        if i == 11 {
            rawtiles.push(tile.clone());
            i = 0;
            tile = Default::default();
        } else if i == 0 {
            let id = &line.unwrap();
            tile.id = id.clone().replace("Tile ", "").replace(":", "");
            i += 1;
        } else {
            tile.lines.push(line.unwrap().clone());
            i += 1;
        }
    }
    rawtiles.push(tile.clone());

    fn rotate_right(lines: &Vec<String>) -> Vec<String> {
        (0..lines.len()).map(|i| lines.iter().rev().map(|line| line.get(i..i+1).unwrap()).collect::<String>()).collect::<Vec<String>>()
    }

    fn flip(lines: &Vec<String>) -> Vec<String> {
        lines.iter().rev()
            .map(|s| s.to_string())
            .collect::<Vec<String>>()
    }

    fn right_edge(lines: &Vec<String>) -> String {
        lines.iter().map(|line| line.chars().last().unwrap()).collect::<String>()
    }
    fn left_edge(lines: &Vec<String>) -> String {
        lines.iter().map(|line| line.chars().next().unwrap()).collect::<String>()
    }

    fn inner(lines: &Vec<String>) -> Vec<String> {
        lines[1..lines.len()-1].iter()
            .map(|line| line[1..line.len()-1].to_string())
            .collect::<Vec<String>>()
    }

    let l = &rawtiles.iter().next().unwrap().lines;
    println!("A\n{}\n", l.iter().as_slice().join("\n"));
    println!("B\n{}\n", inner(l).iter().as_slice().join("\n"));

    let mut tiles = HashMap::<TileId, Tile>::new();

    for rawtile in rawtiles.iter_mut() {
        /*
         * From each raw tile, create its 8 rotations/flips.
         * TRBL = top/right/bottom/left, as read in file (top to bottom, left to right)
         * trbl = top/right/bottom/left, reversed

           +T+  +t+
           L0R  R4L
           +B+  +b+

           +l+  +r+
           B1T  b5t
           +r+  +l+

           +b+  +B+
           r2l  l6r
           +t+  +T+

           +R+  +L+
           t3b  T7B
           +L+  +R+
         */
        let mut lines = rawtile.lines.clone();
        for dir in 0..4 {
            //println!("{}/{}", rawtile.id, dir);
            let id = TileId{num: rawtile.id.parse::<u16>().unwrap(), dir: dir};
            let tile = Tile {
                id: id,
                right: right_edge(&lines),
                bottom: lines[lines.len()-1].to_string(),
                left: left_edge(&lines),
                top: lines[0].to_string(),
                to_rights: HashSet::new(),
                to_bottoms: HashSet::new(),
                inner_lines: inner(&lines),
            };
            tiles.insert(id, tile);
            lines = rotate_right(&lines);
        }
        lines = flip(&lines);
        for dir in 5..8 {
            //println!("{}/{}", rawtile.id, dir);
            let id = TileId{num: rawtile.id.parse::<u16>().unwrap(), dir: dir};
            let tile = Tile {
                id: id,
                right: right_edge(&lines),
                bottom: lines[lines.len()-1].to_string(),
                left: left_edge(&lines),
                top: lines[0].to_string(),
                to_rights: HashSet::new(),
                to_bottoms: HashSet::new(),
                inner_lines: inner(&lines),
            };
            tiles.insert(id, tile);
            lines = rotate_right(&lines);
        }
    }

    // The grid will be filled by row from the top-left corner.  This will require checking for
    // tiles that are valid to the right and/or bottom of existing tiles.  Precalculate that for
    // all tiles: given a tile's transformed right/bottom edges, find all tiles with a matching
    // left/top edge.
    let lefts = tiles.values()
        .map(|tile| (tile.id, tile.left.to_string()))
        .collect::<HashMap<TileId, String>>();
    let tops = tiles.values()
        .map(|tile| (tile.id, tile.top.to_string()))
        .collect::<HashMap<TileId, String>>();
    for tile in tiles.values_mut() {
        for (id, left) in &lefts {
            if *left == tile.right && id.num != tile.id.num {
                tile.to_rights.insert(*id);
               // println!("{} right of {}", id, tile.id);
            }
        }
        for (id, top) in &tops {
            if *top == tile.bottom && id.num != tile.id.num {
                tile.to_bottoms.insert(*id);
                //println!("{} bottom of {}", id, tile.id);
            }
        }
    }
    println!("read tiles");

    let sq = (rawtiles.len() as f32).sqrt() as usize;
    for t in tiles.values() {
        //println!("checking from {}", t.id);
        let unused_tile_nums = tiles.keys().map(|id| id.num).filter(|num| *num != t.id.num).collect::<HashSet<u16>>();
        let sols = attempt(&tiles, &unused_tile_nums, sq, &vec![t.id]);
        if sols.len() > 0 {
            for sol in sols {
                println!("allowed from {}\n{}\n", t.id, ids_to_grid(&sol, sq));
                let inner_string = ids_to_inner(&tiles, &sol, sq);
                println!("{}\n\n", inner_string);
            }
        }
    }

}

use std::io::{self, BufRead};
use std::vec::Vec;
use std::collections::{HashSet, HashMap};
use std::fmt;


#[derive(Debug, Clone)]
struct RawTile {
    id: String,
    lines: Vec<String>,
    top: String,
    left: String,
    bottom: String,
    right: String,
}

impl Default for RawTile {
    fn default() -> Self { RawTile{
        id: "".to_string(),
        lines: Vec::<String>::new(),
        top: "".to_string(),
        bottom: "".to_string(),
        left: "".to_string(),
        right: "".to_string(),
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
}

impl PartialEq for Tile {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

fn to_string<'a>(tiles: &Vec<TileId>) -> String {
    tiles.chunks((tiles.len() as f32).sqrt() as usize)
        .map(|chunk| chunk.iter().fold(String::new(), |acc, arg| acc + " " + &arg.to_string()))
        .fold(String::new(), |acc, arg| acc + "\n" + &arg)
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

    fn reversed(s: &str) -> String {
        s.chars().clone().rev().collect::<String>()
    }

    let mut tiles = HashMap::<TileId, Tile>::new();

    for rawtile in rawtiles.iter_mut() {
        rawtile.top = rawtile.lines[0].clone();
        rawtile.bottom = rawtile.lines[9].clone();
        rawtile.left = rawtile.lines.iter().map(|line| line.chars().next().unwrap()).collect::<String>();
        rawtile.right = rawtile.lines.iter().map(|line| line.chars().last().unwrap()).collect::<String>();
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
        for dir in 0..8 {
            let id = TileId{num: rawtile.id.parse::<u16>().unwrap(), dir: dir};
            let tile = Tile {
                id: id,
                right: match dir {
                    0 => rawtile.right.to_string(),
                    1 => rawtile.top.to_string(),
                    2 => reversed(&rawtile.left),
                    3 => reversed(&rawtile.bottom),
                    4 => rawtile.left.to_string(),
                    5 => reversed(&rawtile.top),
                    6 => reversed(&rawtile.right),
                    7 => rawtile.bottom.to_string(),
                    _ => {println!("oh no"); "".to_string()},
                },
                bottom: match dir {
                    0 => rawtile.bottom.to_string(),
                    1 => reversed(&rawtile.right),
                    2 => reversed(&rawtile.top),
                    3 => rawtile.left.to_string(),
                    4 => reversed(&rawtile.bottom),
                    5 => reversed(&rawtile.left),
                    6 => rawtile.top.to_string(),
                    7 => rawtile.right.to_string(),
                    _ => {println!("oh no"); "".to_string()},
                },
                left: match dir {
                    0 => rawtile.left.to_string(),
                    1 => rawtile.bottom.to_string(),
                    2 => reversed(&rawtile.right),
                    3 => reversed(&rawtile.top),
                    4 => rawtile.right.to_string(),
                    5 => reversed(&rawtile.bottom),
                    6 => reversed(&rawtile.left),
                    7 => rawtile.top.to_string(),
                    _ => {println!("oh no"); "".to_string()},
                },
                top: match dir {
                    0 => rawtile.top.to_string(),
                    1 => reversed(&rawtile.left),
                    2 => reversed(&rawtile.bottom),
                    3 => rawtile.right.to_string(),
                    4 => reversed(&rawtile.top),
                    5 => reversed(&rawtile.right),
                    6 => rawtile.bottom.to_string(),
                    7 => rawtile.left.to_string(),
                    _ => {println!("oh no"); "".to_string()},
                },
                to_rights: HashSet::new(),
                to_bottoms: HashSet::new(),
            };
            tiles.insert(id, tile);
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
                println!("{} right of {}", id, tile.id);
            }
        }
        for (id, top) in &tops {
            if *top == tile.bottom && id.num != tile.id.num {
                tile.to_bottoms.insert(*id);
                println!("{} bottom of {}", id, tile.id);
            }
        }
    }
    println!("read tiles");


    let sq = (rawtiles.len() as f32).sqrt() as usize;
    for t in tiles.values() {
        println!("checking from {}", t.id);
        let unused_tile_nums = tiles.keys().map(|id| id.num).filter(|num| *num != t.id.num).collect::<HashSet<u16>>();
        let sols = attempt(&tiles, &unused_tile_nums, sq, &vec![t.id]);
        if sols.len() > 0{
            println!("allowed from {}\n{}", t.id, sols.iter().map(to_string).fold(String::new(), |acc, arg| acc + "\n\n" + &arg));
        }
    }

}

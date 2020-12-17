using System;
using System.Collections.Generic;
using System.Linq;

public class Grid
{
    const string TEST = @".#.
..#
###";

    const string PROB = @"#......#
##.#..#.
#.#.###.
.##.....
.##.#...
##.#....
#####.#.
##.#.###";

    const char ACTIVE = '#';

    struct Coord {
        static int[] OFFSETS = new int[]{-1, 0, 1};

        public Coord(int x, int y, int z, int w) {
            this.x = x;
            this.y = y;
            this.z = z;
            this.w = w;
        }

        public int x { get; }
        public int y { get; }
        public int z { get; }
        public int w { get; }

        public override int GetHashCode() {
            return x * 31 + y * 11 + z * 7 + w;
        }

        public IEnumerable<Coord> Neighbors {
            get {
                foreach (int dw in OFFSETS) {
                    foreach (int dz in OFFSETS) {
                        foreach (int dy in OFFSETS) {
                            foreach (int dx in OFFSETS) {
                                if (dx == 0 && dy == 0 && dz == 0 && dw == 0) {
                                    continue;
                                }
                                yield return new Coord(x + dx, y + dy, z + dz, w + dw);
                            }
                        }
                    }
                }
            }
        }
    }


    class Layer {
        public Layer(int z, int w) {
            this.z = z;
            this.w = w;
        }

        public int z { get; }
        public int w { get; }

        ISet<Coord> active = new HashSet<Coord>();

        public void SetActive(int x, int y) {
            active.Add(new Coord(x, y, z, w));
        }

        public void SetInactive(int x, int y) {
            active.Remove(new Coord(x, y, z, w));
        }

        public int CountActive { get => active.Count; }

        public int MinX { get => active.Select(c => c.x).DefaultIfEmpty(0).Min(); }
        public int MinY { get => active.Select(c => c.y).DefaultIfEmpty(0).Min(); }
        public int MaxX { get => active.Select(c => c.x).DefaultIfEmpty(0).Max(); }
        public int MaxY { get => active.Select(c => c.y).DefaultIfEmpty(0).Max(); }

        public bool IsActive(int x, int y) {
            return active.Contains(new Coord(x, y, z, w));
        }

        public override string ToString() {
            var grid = "";
            for (int y = Math.Min(0, MinY); y <= MaxY; y++) {
                for (int x = Math.Min(0, MinX); x <= MaxX; x++) {
                    grid += IsActive(x, y) ? "#" : ".";
                }
                grid += "\n";
            }
            return String.Format("layer {0},{1}\n", z, w) +
                String.Join("\n", grid);
        }
    }

    Dictionary<(int z, int w), Layer> layers = new Dictionary<(int z, int w), Layer>();

    public Grid(string initial) {
        int z = 0, y = 0, w = 0;
        var layer = GetLayer(z, w);
        foreach (string line in initial.Split("\n")) {
            for (int x = 0; x < line.Length; x++) {
                if (line[x] == ACTIVE) {
                    layer.SetActive(x, y);
                }
            }
            y += 1;
        }
    }

    public int MinX { get => layers.Values.Min(layer => layer.MinX); }
    public int MaxX { get => layers.Values.Max(layer => layer.MaxX); }
    public int MinY { get => layers.Values.Min(layer => layer.MinY); }
    public int MaxY { get => layers.Values.Max(layer => layer.MaxY); }
    public int MinZ { get => layers.Keys.Min(t => t.z); }
    public int MaxZ { get => layers.Keys.Max(t => t.z); }
    public int MinW { get => layers.Keys.Min(t => t.w); }
    public int MaxW { get => layers.Keys.Max(t => t.w); }

    public Grid Step() {
        var grid = new Grid("");
        int minW = MinW - 1, maxW = MaxW + 1,
            minZ = MinZ - 1, maxZ = MaxZ + 1,
            minY = MinY - 1, maxY = MaxY + 1,
            minX = MinX - 1, maxX = MaxX + 1;
        for (int w = minW; w <= maxW; w++) {
            for (int z = minZ; z <= maxZ; z++) {
                var layer = GetLayer(z, w);
                for (int y = minY; y <= maxY; y++) {
                    for (int x = minX; x <= maxX; x++) {
                        //Console.WriteLine("check {0}, {1}, {2}", x, y, z);
                        var count = new Coord(x, y, z, w).Neighbors
                            .Sum(nc => GetLayer(nc.z, nc.w).IsActive(nc.x, nc.y) ? 1 : 0);
                        if (GetLayer(z, w).IsActive(x, y)) {
                            if (count == 2 || count == 3) {
                                //Console.WriteLine("{3} a -> a {0}, {1}, {2}", x, y, z, count);
                                grid.GetLayer(z, w).SetActive(x, y);
                            } else {
                                //Console.WriteLine("{3} a -> i {0}, {1}, {2}", x, y, z, count);
                                grid.GetLayer(z, w).SetInactive(x, y);
                            }
                        } else {
                            if (count == 3) {
                                //Console.WriteLine("{3} i -> a {0}, {1}, {2}", x, y, z, count);
                                grid.GetLayer(z, w).SetActive(x, y);
                            } else {
                                //Console.WriteLine("{3} i -> i {0}, {1}, {2}", x, y, z, count);
                                grid.GetLayer(z, w).SetInactive(x, y);
                            }
                        }
                    }
                }
            }
        }
        return grid;
    }

    Layer GetLayer(int z, int w) {
        if (layers.ContainsKey((z, w))) return layers[(z, w)];
        return layers[(z, w)] = new Layer(z, w);
    }

    public override string ToString() {
        return String.Join("\n", layers.Keys
            .OrderBy(t => t.w)
            .ThenBy(t => t.z)
            .Select(k => layers[k].ToString()));
    }

    public static void Main(string[] args)
    {
        var grid = new Grid(PROB);
        Console.WriteLine(grid.ToString());
        Console.WriteLine("-------");
        for (var step = 1; step <= 6; step++) {
            grid = grid.Step();
            Console.WriteLine(grid.ToString());
            Console.WriteLine("after step {0}: total {1}", step, grid.layers.Values.Sum(layer => layer.CountActive));
        }
    }
}


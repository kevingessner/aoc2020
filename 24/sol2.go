package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type Pos struct {
	x int
	y int
}

func (p Pos) w() Pos {
	return Pos{p.x - 1, p.y}
}
func (p Pos) e() Pos {
	return Pos{p.x + 1, p.y}
}
func (p Pos) nw() Pos {
	return Pos{p.x - 1, p.y + 1}
}
func (p Pos) ne() Pos {
	return Pos{p.x, p.y + 1}
}
func (p Pos) sw() Pos {
	return Pos{p.x, p.y - 1}
}
func (p Pos) se() Pos {
	return Pos{p.x + 1, p.y - 1}
}

type Grid struct {
	grid map[Pos]bool
}

func min(x, y int) int {
	if x < y {
		return x
	}
	return y
}

func max(x, y int) int {
	if x > y {
		return x
	}
	return y
}

func (grid *Grid) bounds() (int, int, int, int) {
	var minY, maxY, minX, maxX int
	for pos, _ := range grid.grid {
		minY = min(minY, pos.y)
		minX = min(minX, pos.x)
		maxY = max(maxY, pos.y)
		maxX = max(maxX, pos.x)
	}
	return minX, maxX, minY, maxY
}

func (grid *Grid) print() {
	minX, maxX, minY, maxY := grid.bounds()
	for y := maxY; y >= minY; y-- {
		fmt.Printf("% 3d%s", y, strings.Repeat(" ", y-minY))
		for x := minX; x <= maxX; x++ {
			var c byte
			if grid.grid[Pos{x, y}] {
				c = 'X'
			} else {
				c = '_'
			}
			marker := ' '
			if (x == 0 || x == 1) && y == 0 {
				marker = '!'
			}
			fmt.Printf("%c%c", marker, c)
		}
		fmt.Println()
	}
}

func (grid *Grid) count() int {
	c := 0
	for _, on := range grid.grid {
		if on {
			c++
		}
	}
	return c
}

func (grid *Grid) flip(pos Pos) {
	if on, present := grid.grid[pos]; !present || !on {
		grid.grid[pos] = true
	} else if on {
		grid.grid[pos] = false
	}
}

func (grid *Grid) handleDirections(line string) {
	pos := Pos{0, 0}
	for i := 0; i < len(line); i++ {
		switch line[i] {
		case 'w':
			pos = pos.w()
			break
		case 'e':
			pos = pos.e()
			break
		case 'n':
			i++
			switch line[i] {
			case 'w':
				pos = pos.nw()
				break
			case 'e':
				pos = pos.ne()
				break
			}
			break
		case 's':
			i++
			switch line[i] {
			case 'w':
				pos = pos.sw()
			case 'e':
				pos = pos.se()
			}
		}
	}
	grid.flip(pos)
}

func (grid *Grid) onNeighbors(pos Pos) int {
	c := 0
	for _, neighbor := range [6]Pos{pos.w(), pos.e(), pos.nw(), pos.ne(), pos.sw(), pos.se()} {
		if grid.grid[neighbor] {
			c++
		}
	}
	return c
}

func (grid *Grid) handleDayFlips() {
	newgrid := make(map[Pos]bool)
	minX, maxX, minY, maxY := grid.bounds()
	// Go one past the bounds in each direction, as tiles just off the current grid can be flipped by the current grid.
	for x := minX - 1; x <= maxX+1; x++ {
		for y := minY - 1; y <= maxY+1; y++ {
			pos := Pos{x, y}
			n := grid.onNeighbors(pos)
			on := grid.grid[pos]
			if on {
				// black
				newgrid[pos] = !(n == 0 || n > 2)
			} else {
				// white
				newgrid[pos] = (n == 2)
			}
			//fmt.Printf("pos %v (%v -> %v) has %d nbs\n", pos, on, newgrid[pos], n)
		}
	}
	grid.grid = newgrid
}

func main() {
	fmt.Println("hello")
	grid := Grid{make(map[Pos]bool)}
	reader := bufio.NewReader(os.Stdin)
	for line, err := reader.ReadString('\n'); err == nil; line, err = reader.ReadString('\n') {
		fmt.Printf("read " + line)
		grid.handleDirections(line)
	}
	fmt.Printf("day 0: %d\n", grid.count())
	for day := 1; day <= 100; day++ {
		grid.handleDayFlips()
		//grid.print()
		fmt.Printf("day %d: %d\n", day, grid.count())
	}
	grid.print()
}

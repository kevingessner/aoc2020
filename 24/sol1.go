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

func (grid *Grid) print() {
	var minY, maxY, minX, maxX int
	for pos, _ := range grid.grid {
		minY = min(minY, pos.y)
		minX = min(minX, pos.x)
		maxY = max(maxY, pos.y)
		maxX = max(maxX, pos.x)
	}
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

func main() {
	fmt.Println("hello")
	grid := Grid{make(map[Pos]bool)}
	reader := bufio.NewReader(os.Stdin)
	for line, err := reader.ReadString('\n'); err == nil; line, err = reader.ReadString('\n') {
		fmt.Printf("read " + line)
		grid.handleDirections(line)
		grid.print()
	}
	fmt.Printf("flipped: %d\n", grid.count())
}

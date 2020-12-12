inp <- as.list(scan("prob.in", ""))
mat <- sapply(inp, function(s) strsplit(s, ""))

EMPTY <- "L"
OCCUPIED <- "#"
FLOOR <- "."

DIRS <- expand.grid(c(-1, 0, 1), c(-1, 0, 1))

# number of occupied seats visible at mat[[iy]][[ix]]
count_vis_occ <- function(iy, ix, mat, d = FALSE) {
    c <- 0
    maxy <- length(mat)
    maxx <- length(mat[[iy]])
    for (d in 1:nrow(DIRS)) {
        dy <- dirs[d, "dy"]
        dx <- dirs[d, "dx"]
        if (dx == 0 && dy == 0) next;
        y <- iy + dy
        x <- ix + dx
        while (y >= 1 && y <= maxy && x >= 1 && x <= maxx) {
            if (mat[[y]][[x]] == OCCUPIED) {
                c <- c + 1
                break;
            } else if(mat[[y]][[x]] == EMPTY) {
                break;
            }
            y <- y + dy
            x <- x + dx
        }
    }
    c
}

# number of occupied seats total
count_occ <- function(mat, d = FALSE) {
    c <- 0
    cols <- 1:length(mat[[1]])
    for (y in 1:length(mat)) {
        c <- c + sum(mat[[y]][cols] == OCCUPIED)
    }
    c
}

# update a single seat position
replace <- function(s, y, x, mat) {
    c <- count_vis_occ(y, x, mat)
    if (s == EMPTY && c == 0) OCCUPIED
    else if(s == OCCUPIED && c >= 5) EMPTY
    else s
}

# iterate once
step <- function(mat) {
    lapply(seq_along(mat), function(y) {
        sapply(seq_along(mat[[y]]), function(x) replace(mat[[y]][[x]], y, x, mat), simplify="array")
    })
}

# TRUE if the matrices are equal at every position
mateq <- function(m1, m2) {
    ret <- TRUE;
    for (y in 1:length(m1)) {
        if (!all(m1[[y]] == m2[[y]])) {
            ret <- FALSE;
            break;
        }
    }
    ret;
}

loop <- function(mat) {
    loops <- 0
    nextmat <- step(mat)
    while (!mateq(mat, nextmat)) {
        mat <- nextmat
        nextmat <- step(mat)
        loops <- loops + 1
    }
    print(c("done in ", loops))
    nextmat
}

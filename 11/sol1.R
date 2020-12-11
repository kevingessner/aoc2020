inp <- as.list(scan("prob.in", ""))
mat <- sapply(inp, function(s) strsplit(s, ""))

EMPTY <- "L"
OCCUPIED <- "#"
FLOOR <- "."

# number of occupied seats adjacent to mat[[iy]][[ix]]
count_adj_occ <- function(iy, ix, mat, d = FALSE) {
    c <- 0
    row <- mat[[iy]]
    for (y in max(iy-1, 1):min(iy+1, length(mat))) {
        for (x in max(ix-1, 1):min(ix+1, length(row))) {
            if (x == ix && y == iy) next;
            if (d) print(paste(y, x, mat[[y]][[x]]))
            if (mat[[y]][[x]] == OCCUPIED) c <- c + 1
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
    c <- count_adj_occ(y, x, mat)
    if (s == EMPTY && c == 0) OCCUPIED
    else if(s == OCCUPIED && c >= 4) EMPTY
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
    nextmat <- step(mat)
    while (!mateq(mat, nextmat)) {
        mat <- nextmat
        nextmat <- step(mat)
    }
    nextmat
}

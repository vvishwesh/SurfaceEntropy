## This R-script calculates entropies for GENSURF outputs
## Need .srf files

## Author: Vishwesh Venkatraman

args = commandArgs(TRUE)

srffile = args[1]
nbins = as.integer(args[2])


## Create connection
con <- file(description=srffile, open="r")
foundXYZ = FALSE
foundFaces = FALSE
cnames <- NULL
proplist <- list()
facelist <- list()

i <- 1

## Loop over a file connection
#for(i in 1:n) {
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
    #line <- scan(file=con, nlines=1, quiet=TRUE)

    #cat(line, "\n")

    if (startsWith(line, "# Area"))
    {
        #print("Found #Area tag")
        next;
    }

    if (startsWith(line, "# X Y Z"))
    {
        #print("Found # X tag")
        foundXYZ = TRUE;
        line = substr(line, 3, nchar(line))
        cnames <- unlist(strsplit(line, split=" "))
        #print("Created dataframe")
        next;
    }

    if (startsWith(line, "# EDGES"))
    {
        #print("Found # EDGES tag")
        foundXYZ = FALSE;
        next;
    }

    if (startsWith(line, "# FACES"))
    {
        #print("Found # EDGES tag")
        i = 1;
        foundFaces = TRUE;
        next;
    }

    ## do something on a line of data
    if (foundXYZ)
    {
        myvec <- as.vector(unlist(strsplit(line, split=" ")))
        proplist[[i]] <- myvec
        i <- i + 1
    }

    if (foundFaces)
    {
        myvec <- as.vector(unlist(strsplit(line, split=" ")))
        facelist[[i]] <- myvec
        i <- i + 1
    }
}
close(con)

df <- data.frame(matrix(unlist(proplist), nrow=length(proplist), byrow=T),stringsAsFactors=FALSE)
colnames(df) <- cnames
rm(proplist)
df$X <- NULL
df$Y <- NULL
df$Z <- NULL

faces <- data.frame(matrix(unlist(facelist), nrow=length(facelist), byrow=T),stringsAsFactors=FALSE)
colnames(faces) <- c("F1", "F2", "F3", "Area")
rm(facelist)



SHPIDX <- numeric(nrow(faces))
CURV <- numeric(nrow(faces))


for (i in 1:nrow(faces)) {

    idx1 <- as.integer(faces$F1[i])
    idx2 <- as.integer(faces$F2[i])
    idx3 <- as.integer(faces$F3[i])

    CURV[i] = (as.numeric(df$CURV[idx1]) + as.numeric(df$CURV[idx2]) + as.numeric(df$CURV[idx3]))/3; # CURV

    SHPIDX[i] = (as.numeric(df$SHPIDX[idx1]) + as.numeric(df$SHPIDX[idx2]) + as.numeric(df$SHPIDX[idx3]))/3; # SHPIDX
}

nr = nrow(faces)


Area <- as.numeric(faces$Area)
rm(df)
rm(faces)


CURV[is.nan(CURV)] <- NA
SHPIDX[is.nan(SHPIDX)] <- NA

xbreaks = seq(min(CURV, na.rm=T), max(CURV, na.rm=T), length.out = nbins+1)
hst_CURV = hist(CURV, breaks = xbreaks, plot = FALSE)
xbreaks = seq(min(SHPIDX, na.rm=T), max(SHPIDX, na.rm=T), length.out = nbins+1)
hst_SHPIDX = hist(SHPIDX, breaks = xbreaks, plot = FALSE)



curv_entropy = 0
shpidx_entropy = 0


for (i in 1:nr) {
    
    val_shpidx = 0
    val_curv = 0
    
    value <- CURV[i]
    if (!is.na(value)) {
        idx <- findInterval(value, hst_CURV$breaks, all.inside = TRUE)
        p = hst_CURV$counts[idx]/nr
        xval = p * log2(p)
        if (!is.na(xval)) {
            val_curv = xval
        }
    }

    value <- SHPIDX[i]
    if (!is.na(value)) {
        idx <- findInterval(value, hst_SHPIDX$breaks, all.inside = TRUE)
        p = hst_SHPIDX$counts[idx]/nr
        xval = p * log2(p)
        if (!is.na(xval)) {
            val_shpidx = xval
        }
    }

    
    curv_entropy = curv_entropy + val_curv * Area[i]
    shpidx_entropy = shpidx_entropy + val_shpidx * Area[i]
    
}

curv_entropy = curv_entropy * (-1)
shpidx_entropy = shpidx_entropy * (-1)


cat(tools::file_path_sans_ext(basename(srffile)), sprintf(curv_entropy, fmt='%.3f'), sprintf(shpidx_entropy, fmt='%.3f'), "\n", file="")


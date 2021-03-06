#' Save/Load an ImmuneSpaceConnection object from disk
#' 
#' Connection can hold a lot of data in cache. If a lot of work has 
#' been done (e.g: lots of downloaded datasets and gene-expression matrices),
#' it can be useful to save the connection for later work or even offline use.
#' 
#' @param file The file name to be saved to or loaded from
#' 
#' @examples
#' #Sample saved connection with pre-downloaded expression matrices and datasets
#' saved <- system.file("extdata/saved_con.rds", package = "ImmuneSpaceR")
#' new_con <- loadConnection(saved)
#' new_con
#' names(new_con$data_cache)
#' \dontrun{
#'   saveConnection(new_con, tempfile())
#' }
#' 
#' @rdname loadConnection
#' @export
#' @return An ImmuneSpaceConnection object
loadConnection <- function(file){
  con <- readRDS(file = file)
  conType <- class(con)
  if(conType == 'ImmuneSpaceConnection') 
    labkey.url.base <- con$config$labkey.url.base
  else
    stop("invalid ImmuneSpaceConnection object!")
  
  #init labkey.setCurlOptions
  labkey.setCurlOptions(ssl.verifyhost = 2, sslversion=1)
  con
}

#' @param con An \code{ImmuneSpaceConnection}. The connection to save to file. 
#'  To be loaded later using \code{loadConnection}.
#' 
#' @rdname loadConnection
#' @export
saveConnection <- function(con, file){
  saveRDS(con, file = file)
}

#' ImmuneSpace palette
#' 
#' Create a color gradient of the selected length that matches the ImmuneSpace
#' theme.
#' 
#' @param n A \code{numeric}. The length of the desired palette.
#' @return A \code{character} vector colors in hexadecimal code of length
#'  \code{n}.
#' 
#' @importFrom gplots colorpanel
#' @export
#' @examples
#' plot(1:10, col = ISpalette(10), cex = 10, pch = 16)
ISpalette <- function(n){
  colorpanel(n, low = "#268bd2", mid = "#fdf6e3", high = "#dc322f")
}

#' theme_IS
#' 
#' Theme that matches ImmuneSpace's graphic style. The theme modifies the 
#' background, the grid lines, the axis, and the colors used by continuous and
#' gradient scales.
#' 
#' @param base_size A \code{numeric}. Base font size.
#' 
#' @return A theme object
#' 
#' @details
#' List of modified ggplot2 elements: \code{panel.background},
#' \code{panel.grid.major}, \code{panel.grid.minor}, \code{axis.ticks},
#' \code{axis.line.x}, \code{axis.line.y}, \code{plot.title}, and
#' \code{strip.background}.
#' 
#' The default \code{scale_fill_gradient}, \code{scale_fill_continuous},
#' \code{scale_colour_gradient} and \code{scale_colour_continous} are also
#' replaced by a custom scale.
#' 
#' @importFrom ggplot2 theme theme_classic element_line element_text element_rect
#' @importFrom ggplot2 continuous_scale rel
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(data = mtcars) + geom_point(aes(x = mpg, y = cyl, color = hp)) + facet_grid(vs ~ am)
#' p + theme_IS()
theme_IS <- function(base_size = 12) {
  .override_scale()
  theme(text = element_text(size = base_size)) +
  #theme(axis.text.x = element_text(angle = 45)) +
  theme(panel.background = element_rect(fill = "#FDF6E3")) +
  theme(panel.grid.major = element_line(colour = "#ded8d5", linetype = "dashed")) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.ticks = element_blank()) +
  #theme(axis.line = element_line(size = 0.5, colour = "black")) +
  theme(axis.line.x = element_line(size = 0.5, colour = "black")) +
  theme(axis.line.y = element_line(size = 0.5, colour = "black")) +
  theme(plot.title = element_text(size = rel(1))) +
  theme(strip.background = element_rect(colour = "white", fill = "white")) #bg of facets
}

# Add scales that use a different color scheme to the environment.
#' @importFrom ggplot2 update_geom_defaults
#' @importFrom scales seq_gradient_pal
.override_scale <- function(envir = as.environment(1)){
  update_geom_defaults("boxplot", list(fill = "#268bd2"))
  scale_updates <- list( 
    scale_fill_continuous = function(...) continuous_scale('fill', 'scale_IS', seq_gradient_pal("#268bd2", "#dc322f"), ...),
    scale_fill_gradient = function(...) continuous_scale('fill', 'scale_IS', seq_gradient_pal("#268bd2", "#dc322f"), ...),
    scale_colour_gradient = function(...) continuous_scale('colour', 'scale_IS', seq_gradient_pal("#268bd2", "#dc322f"), ...),
    scale_colour_continuous = function(...) continuous_scale('colour', 'scale_IS', seq_gradient_pal("#268bd2", "#dc322f"), ...)
  )

  Map(
    function(name, f) assign(name, f, envir = envir),
    names(scale_updates),
    scale_updates
  )
}

#' Write a netrc file
#'
#' Write a netrc file that is valid for accessing ImmuneSpace
#' 
#' @param login A \code{character}. The email address used for loging in on
#'  ImmuneSpace.
#' @param password A \code{character}. The password associated with the login.
#' @param file A \code{character}. The credentials will be written into that
#'  file. If left NULL, the netrc will be written into a temporary file.
#' @export
#' @examples 
#' write_netrc("immunespaceuser@gmail.com", "mypassword")
#' 
write_netrc <- function(login, password, file = NULL){
  string <- paste("machine www.immunespace.org login", login, "password", password)
  if(is.null(file)){
    file <- tempfile()
  } else if(file.exists(file)){
    stop("The file you are trying to write to already exists. Remove manually if you wish to overwrite.")
  }
  write(string, file)
  return(file)
}

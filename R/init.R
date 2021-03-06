.onAttach <- function(libname, pkgname){
  config <- libgit2_config()
  ssh <- ifelse(config$ssh, "YES", "NO")
  https <- ifelse(config$https, "YES", "NO")
  packageStartupMessage(sprintf(
    "Linking to libgit2 v%s, ssh support: %s",
    as.character(config$version), ssh))
  if(length(config$config.global) && nchar(config$config.global)){
    packageStartupMessage(paste0("Global config: ", normalizePath(config$config.global, mustWork = FALSE)))
  } else {
    packageStartupMessage(paste("No global .gitconfig found in:", config$config.home))
  }
  if(length(config$config.system) && nchar(config$config.system))
    packageStartupMessage(paste0("System config: ", config$config.system))
  try({
    settings <- git_config_global()
    name <- subset(settings, name == 'user.name')$value
    email <- subset(settings, name == 'user.email')$value
    if(length(name) || length(email)){
      packageStartupMessage(sprintf("Default user: %s <%s>", as_string(name), as_string(email)))
    } else {
      packageStartupMessage("No default user configured")
    }
  })

  # Load tibble (if available) for pretty printing
  if(interactive() && is.null(.getNamespace('tibble'))){
    tryCatch({
      getNamespace('tibble')
    }, error = function(e){})
  }
}

.onLoad <- function(libname, pkgname) {

  if (identical(Sys.getenv("IN_PKGDOWN"), "true") &&
      !global_user_is_configured()) {
    configure_global_user()
  }

  invisible()
}

as_string <- function(x){
  ifelse(length(x) > 0, x[1], NA_character_)
}

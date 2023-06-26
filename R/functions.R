#' Download and save the Eurostat data about beneficiaries of temporary protection
#' 
#' Source: https://ec.europa.eu/eurostat/databrowser/product/page/MIGR_ASYTPSM
#' 
#' @return A data frame containing data on beneficiaries of temporary protection
get_beneficiaries <- function() {
    
    path <- "data/beneficiaries.parquet"
        
    get_eurostat("migr_asytpsm") |>
        filter(
            sex == "T",
            age == "TOTAL",
            citizen == "TOTAL"
        ) |> 
        select(-unit, -sex, -age, -citizen) |> 
        label_eurostat() |> 
        write_parquet(
            path
        )
    
    path
    
}

#' Download and save the Eurostat data about applicants of temporary protection
#' 
#' Source: https://ec.europa.eu/eurostat/databrowser/view/migr_asypenctzm/default/table?lang=en
#'
#' @return A data frame containing data on applicants of temporary protection
get_applicants <- function() {
    
    path <- "data/applicants.parquet"
    
    get_eurostat("migr_asypenctzm") |>
        janitor::remove_constant() |> 
        filter(
            age == "TOTAL",
            sex == "T",
            citizen == "TOTAL"
        ) |> 
        select(-citizen, -sex, -age) |> 
        label_eurostat() |> 
        write_parquet(
            path
        )
    
    path
}

#' Download and save the Eurostat data about grants of temporary protection
#' 
#' Source: https://ec.europa.eu/eurostat/databrowser/view/MIGR_ASYTPFM$DV_1383/default/table?lang=en&category=mi.mci.mci_asytp
#'
#' @return A data frame containing data on grants of temporary protection
get_grants <- function() {
    path <- "data/grants.parquet"
    
    get_eurostat("migr_asytpfm") |> 
        filter(
            sex == "T",
            age == "TOTAL",
            citizen == "TOTAL"
        ) |> 
        select(-unit, -citizen, -sex, -age) |> 
        label_eurostat() |> 
        write_parquet(
            path
        )
    
    path
}


#' Download and save the Eurostat data about decisions in cases of temporary protection
#' 
#' Source: https://ec.europa.eu/eurostat/databrowser/view/migr_asydcfstq/default/table?lang=en
#'
#' @return A data frame containing data on decisions in cases of temporary protection
get_decisions <- function() {
    
    path <- "data/decisions.parquet"
    
    get_eurostat("migr_asydcfstq")  |> 
        filter(
            citizen == "TOTAL",
            sex == "T",
            age == "TOTAL",
            decision %in% c("TOTAL", "TOTAL_POS")
        ) |> 
        select(-citizen, -sex, -age, -unit) |> 
        label_eurostat() |> 
        pivot_wider(names_from = decision, values_from = values) |> 
        write_parquet(
            path
        )
    
    path
}

#' Download and save the Eurostat data about population by country
#' 
#' Source: https://ec.europa.eu/eurostat/databrowser/view/demo_pjan/default/table
#'
#' @return A data frame containing data on population by country
get_population <- function() {
    path <- "data/population.parquet"
    
    get_eurostat("demo_pjan") |> 
        filter(
            age == "TOTAL",
            sex == "T"
        ) |> 
        select(-unit, -age, -sex) |> 
        label_eurostat() |> 
        write_parquet(
            path
        )
    
    path
}


#' Join together all the data created by above functions
#'
#' @return
combine_data <- function(beneficiaries, applicants, grants, decisions, population) {
    
    beneficiaries <- read_parquet(beneficiaries)
    applicants <- read_parquet(applicants)
    grants <- read_parquet(grants)
    decisions <- read_parquet(decisions)
    population <- read_parquet(population)
    
    path <- "data/combined_data.parquet"
    
    beneficiaries |> 
        mutate(
            year = year(time)
        ) |> 
        rename(beneficiaries = values) |> 
        inner_join(
            population |> 
                group_by(geo) |> 
                filter(time == max(time)) |> 
                ungroup() |> 
                select(geo, pop = values),
            by = c("geo")
        ) |> 
        full_join(
            applicants |> 
                rename(applicants = values),
            by = c("geo", "time")
        ) |> 
        inner_join(
            grants |> 
                rename(grants = values),
            by = c("geo", "time")
        ) |> 
        rename(country = geo) |> 
        mutate(
            country = ifelse(str_detect(country, "Germany"), "Germany", country)
        ) |> 
        inner_join(
            metill::country_names(),
            by = "country"
        ) |> 
        select(
            -year, -country
        ) |> 
        pivot_longer(
            c(-land, -time, -pop)
        ) |> 
        group_by(land) |> 
        mutate(pop = max(pop, na.rm = T)) |> 
        ungroup() |> 
        mutate(per_pop = value / pop * 1e3) |> 
        write_parquet(
            path
        )
    
    path
}

load_combined_data <- function(combine_data) {
    
    read_parquet(combine_data)
    
}




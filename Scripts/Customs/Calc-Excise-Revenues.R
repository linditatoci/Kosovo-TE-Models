'Preparation of Aggregated Revenue Tables
'
start.time <- proc.time()
# 
# # I. Excise Revenues  --------------------------------------------


              # Function to extract columns and add scenario
              extract_TypeOfProducts_fun <- function(dt, scenario) {
                                        dt[, .(TypeOfProducts,calc_excise, scenario = scenario)]
                                      }
                                      
              

# 1. Type of Products ---------------------------------------------------

      # 1.1 BU ------------------------------------------------------------------
      
                    extracted_tables_bu <- mapply(extract_TypeOfProducts_fun, Customs_BU_list, scenarios, SIMPLIFY = FALSE)
                    combined_dt <- rbindlist(extracted_tables_bu)
                    
                    combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]%>%as.data.table()
      
                    customs_d_typeRev_bu <- combined_dt[, .(
                                 calc_excise_duties = sum(calc_excise, na.rm = TRUE)
                                  ), by = .(year, TypeOfProducts)]
                    
                    setnames(customs_d_typeRev_bu, "calc_excise_duties", "calc_excise_bu") 
      
      # 1.2 SIM -----------------------------------------------------------------
      
                    extracted_tables_sim <- mapply(extract_TypeOfProducts_fun, Customs_SIM_list, scenarios, SIMPLIFY = FALSE)
                    combined_dt <- rbindlist(extracted_tables_sim)
                    
                    combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]%>%as.data.table()
                    
                    customs_d_typeRev_sim <- combined_dt[, .(
                      calc_excise_duties = sum(calc_excise, na.rm = TRUE)
                    ), by = .(year, TypeOfProducts)]
                               
                    
                    setnames(customs_d_typeRev_sim, "calc_excise_duties", "calc_excise_sim") 
                    
              # 1.3  MERGED BU AND SIM -----------------------------------------------
              TypeRev_Excise_data <- merge(customs_d_typeRev_bu,customs_d_typeRev_sim,by = c("year", "TypeOfProducts"), all = TRUE)              
              TypeRev_Excise_data<-TypeRev_Excise_data%>%
                dplyr::rename("Baseline"="calc_excise_bu",
                              "Simulation"="calc_excise_sim"
                              )

              
              # da se dodade TypeRev_Excise_data
              
# 2. Chapter ------------------------------------------------------
       # 2.1 BU ------------------------------------------------------------------
              extract_customs_rev_chapter_fun <- function(dt, scenario) {
                                              dt[, .(Chapter,calc_excise, scenario = scenario)]
                                               }
                                            
              extracted_tables_bu <- mapply(extract_customs_rev_chapter_fun, Customs_BU_list, scenarios, SIMPLIFY = FALSE)
              combined_dt <- rbindlist(extracted_tables_bu)
              combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]%>%as.data.table()
              
              customs_d_Chapter_bu <- combined_dt[, .(
                                                    calc_excise_duties = sum(calc_excise, na.rm = TRUE)
                                                  ), by = .(year, Chapter)]
              
              setnames(customs_d_Chapter_bu, "calc_excise_duties", "calc_excise_bu")
              

       # 2.1 SIM -----------------------------------------------------------------

              extract_customs_rev_chapter_fun <- function(dt, scenario) {
                dt[, .(Chapter,calc_excise, scenario = scenario)]
              }
              
              extracted_tables_sim <- mapply(extract_customs_rev_chapter_fun, Customs_SIM_list, scenarios, SIMPLIFY = FALSE)
              combined_dt <- rbindlist(extracted_tables_sim)
              combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]%>%as.data.table( )
              
              customs_d_Chapter_sim <- combined_dt[, .(
                calc_excise_duties = sum(calc_excise, na.rm = TRUE)
              ), by = .(year, Chapter)]
              
              setnames(customs_d_Chapter_sim, "calc_excise_duties", "calc_excise_sim")            



               # 2.3  MERGED BU AND SIM -----------------------------------------------
              Chapter_Excise_data <- merge(customs_d_Chapter_bu,customs_d_Chapter_sim,by = c("year", "Chapter"), all = TRUE)
              
              Chapter_Excise_data<-left_join(Chapter_Excise_data,HS_Sections,by =c("Chapter"))
              
              
              Sections_customs_data<-Chapter_Excise_data%>%
                select(year,Sections,Section_description,calc_excise_bu,calc_excise_sim)%>%
                dplyr::group_by(year,Sections,Section_description)%>%
                dplyr::summarise(
                              Baseline =sum(calc_excise_bu ,na.rm = TRUE),
                              Simulation =sum(calc_excise_sim ,na.rm = TRUE)
                )
              
              
              
              Chapter_Excise_data_agg<-Chapter_Excise_data%>%
                select(year,Chapter,Chapters_description,calc_excise_bu,calc_excise_sim)%>%
                dplyr::group_by(year,Chapter,Chapters_description)%>%
                dplyr::summarise(
                  Baseline =sum(calc_excise_bu ,na.rm = TRUE),
                  Simulation =sum(calc_excise_sim ,na.rm = TRUE)
                )
              
              
              # ova Chapter_Excise_data_agg
              
# 3. MTN ------------------------------------------------------------------
      # 3.1 BU --------------------------------------------------------
              extract_customs_rev_MTN_fun <- function(dt, scenario) {
                                                                      dt[, .(Six_digit,calc_excise, scenario = scenario)]
                                                                    }
              extracted_tables_bu <- mapply(extract_customs_rev_MTN_fun, Customs_BU_list, scenarios, SIMPLIFY = FALSE)
              combined_dt <- rbindlist(extracted_tables_bu)
              combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]%>%as.data.table( )
              
              customs_d_MTN_bu <- combined_dt[, .(
                calc_excise_duties = sum(calc_excise, na.rm = TRUE)
              ), by = .(year, Six_digit)]
              
              setnames(customs_d_MTN_bu, "calc_excise_duties", "calc_excise_bu")
              

      # 3.2 SIM -----------------------------------------------------------------

              
              extracted_tables_sim <- mapply(extract_customs_rev_MTN_fun, Customs_SIM_list, scenarios, SIMPLIFY = FALSE)
              combined_dt <- rbindlist(extracted_tables_sim)
              combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]%>%as.data.table( )
              
              customs_d_MTN_sim <- combined_dt[, .(
                calc_excise_duties = sum(calc_excise, na.rm = TRUE)
              ), by = .(year, Six_digit)]
              
              setnames(customs_d_MTN_sim, "calc_excise_duties", "calc_excise_sim")         
              

               # 3.3 MERGED BU AND SIM ----------------------------------------------------

              MTN_Excise_data <- merge(customs_d_MTN_bu,customs_d_MTN_sim,by = c("year", "Six_digit"), all = TRUE)

             
              MTN_Excise_data_agg<-MTN_Excise_data%>%
                dplyr::group_by(year ,Six_digit)%>%
                dplyr::summarise(calc_excise_bu =sum(calc_excise_bu ,na.rm = TRUE),
                                 calc_excise_sim =sum(calc_excise_sim ,na.rm = TRUE)
                                 )
              
              
              
              MTN_Excise_data_agg$Six_digit <- substr(MTN_Excise_data_agg$Six_digit, 1, 4) %>% 
                                                          paste(substr(MTN_Excise_data_agg$Six_digit, 5, 6))
              
              
              
              # New
              WTO_MTN_subset <- WTO_MTN %>%
                              filter(
                                (SimulationYear >= 2022 & str_detect(HS_year, ">2022")) |
                                  (SimulationYear < 2022 & str_detect(HS_year, "<2022"))
                              )
              

              MTN_Excise_data_agg<-left_join(MTN_Excise_data_agg,WTO_MTN_subset,by =c("Six_digit"))

              MTN_Excise_data_agg <- distinct(MTN_Excise_data_agg)
              
              MTN_Excise_data_agg<-MTN_Excise_data_agg%>%
                dplyr::group_by(year,Product_group)%>%
                dplyr::summarise(
                  Baseline =sum(calc_excise_bu ,na.rm = TRUE),
                  Simulation =sum(calc_excise_sim ,na.rm = TRUE)
                )
              
              MTN_Excise_data_agg$Product_group <- ifelse(is.na( MTN_Excise_data_agg$Product_group), "Other",  MTN_Excise_data_agg$Product_group)

              MTN_Excise_data_agg$Product_group <- factor( MTN_Excise_data_agg$Product_group)
              
# -------------------------------------------------------------------------

              end.time <- proc.time()
              save.time <- end.time - start.time
              cat("\n Number of minutes running-Customs Revenues:", save.time[3] / 60, "\n \n")
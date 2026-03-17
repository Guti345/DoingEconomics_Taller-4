clear all
set more off

cd "C:\Users\anton\OneDrive\Documentos\GitHub\DoingEconomics_Taller-4"

global main "C:\Users\anton\OneDrive\Documentos\GitHub\DoingEconomics_Taller-4"
global graphs "${main}\Outputs\Graphs"
global tables "${main}\Outputs\Tables"
global raw "${main}\Data\Raw"
global clean "${main}\Data\Clean"

import excel "${raw}\haciendo eocnomia 2026.xlsx", clear firstrow // Upload de la base de datos.

* Completar Variable Round
gen id = _n
sort id
replace Round = Round[_n-1] if missing(Round)
drop id

* -------------------------------------------------
* Parte 2.1 Recolectando Datos jugando
* -------------------------------------------------

* 2.1.1 Gráfico Contrubución Promedio

collapse (mean) mean_contribution = Playerscontributions ///
         (mean) mean_payoff = PayoffsinthisGame, by(Round)
		 
save "${clean}\mean_per_round.dta", replace

tsset Round

tsline mean_contribution, ///
    xlabel(1(1)11, labsize(small)) ///
    ylabel(, labsize(small) grid glcolor(gs13)) ///
    xtitle("Ronda", size(medium)) ///
    ytitle("Contribución promedio", size(medium)) ///
    title("Evolución de la contribución promedio", size(medsmall)) ///
    subtitle("Juego por rondas", size(small)) ///
    legend(off) ///
    lcolor(navy) ///
    lwidth(medthick) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

graph export "${graphs}\211_mean_contribution.png", replace width(2000)

* -------------------------------------------------
* Parte 2.2 Describiendo los Datos
* -------------------------------------------------

* Ajuste de tablas fig 2A / 3

local cities Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne

* fig 2A
import excel "${raw}\doing-economics-datafile-working-in-excel-project-2.xlsx", clear firstrow sheet("Fig_2A")
egen mean_contribution_wp = rowmean(`cities')
egen sd_contribution_wp = rowsd(`cities')
keep Period mean_contribution_wp sd_contribution_wp
gen l_CI_wp = mean_contribution_wp - 2*sd_contribution_wp
gen u_CI_wp = mean_contribution_wp + 2*sd_contribution_wp
save "${clean}\data_fig_2A.dta", replace

* fig 3
import excel "${raw}\doing-economics-datafile-working-in-excel-project-2.xlsx", clear firstrow sheet("Fig_3")
egen mean_contribution_np = rowmean(`cities')
egen sd_contribution_np = rowsd(`cities')
keep Period mean_contribution_np sd_contribution_np
drop if missing(Period)
gen l_CI_np = mean_contribution_np - 2*sd_contribution_np
gen u_CI_np = mean_contribution_np + 2*sd_contribution_np
save "${clean}\data_fig_3.dta", replace

* 2.2.1 Replicando Resultados Hermann et al. (2008)

use "${clean}\data_fig_2A.dta", clear

merge 1:1 Period using "${clean}\data_fig_3.dta", nogen

label var mean_contribution_wp "Mean Contribution - With Punishment"
label var mean_contribution_np "Mean Contribution - No Punishment"
label var sd_contribution_wp "Standar Deviation Contribution - With Punishment"
label var sd_contribution_np "Standar Deviation Contribution - No Punishment"
label var u_CI_wp "Upper Confidence Interval Contribution - With Punishment (~95%)"
label var l_CI_wp "Lower Confidence Interval Contribution - With Punishment (~95%)"
label var u_CI_np "Upper Confidence Interval Contribution - No Punishment (~95%)"
label var l_CI_np "Lower Confidence Interval Contribution - No Punishment (~95%)"

save "${clean}\data_comparison_punishment_Hermann(2008).dta", replace

tsset Period

twoway ///
    (line mean_contribution_np Period, ///
        lcolor(navy) lwidth(medthick) lpattern(solid)) ///
    (line mean_contribution_wp Period, ///
        lcolor(maroon) lwidth(medthick) lpattern(dash)), ///
    xlabel(1(1)10, labsize(small)) ///
    ylabel(0(2)20, labsize(small) grid glcolor(gs13)) ///
    xtitle("Período", size(medium)) ///
    ytitle("Contribución promedio", size(medium)) ///
    title("Contribución promedio por período", size(medsmall)) ///
    subtitle("Experimentos con y sin castigo", size(small)) ///
    legend(order(1 "Sin castigo" 2 "Con castigo") ///
           pos(6) rows(1) size(small)) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
	note("Fuente: Datos extraidos de Hermann et al. (2008).")

graph export "${graphs}\mean_contribution_punishment_comparison.png", replace width(2000)

* 2.2.2 Gráfico de Barras primer y último periodo

preserve

keep if inlist(Period, 1, 10)

keep Period mean_contribution_np mean_contribution_wp

reshape long mean_contribution_, i(Period) j(experiment) string

gen exp_label = ""
replace exp_label = "Sin castigo" if experiment == "np"
replace exp_label = "Con castigo" if experiment == "wp"

graph bar mean_contribution_, ///
    over(exp_label, label(labsize(small))) ///
    over(Period, relabel(1 "Primer período" 2 "Último período")) ///
    asyvars ///
    bar(1, color(green)) ///
    bar(2, color(orange)) ///
    blabel(bar, format(%4.2f) size(small)) ///
    legend(order(1 "Con castigo" 2 "Sin Castigo") ///
           pos(6) rows(1)) ///
    ytitle("Contribución promedio") ///
    title("Contribución promedio en el primer y último período") ///
    subtitle("Experimentos con y sin castigo") ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
	note("Fuente: Datos extraidos de Hermann et al. (2008).")

graph export "${graphs}\bar_mean_contribution_P1_P10.png", replace width(2000)

restore

* 2.2.3 Desviación Estandar Periodos 1 y 10

preserve

keep if inlist(Period, 1, 10)

list 

save "${clean}\data_descriptive_P1_P10.dta", replace

restore

preserve

use "${clean}\data_descriptive_P1_P10.dta", clear

local wp_l_p1  = l_CI_wp[1]
local wp_u_p1  = u_CI_wp[1]
local wp_l_p10 = l_CI_wp[2]
local wp_u_p10 = u_CI_wp[2]

local np_l_p1  = l_CI_np[1]
local np_u_p1  = u_CI_np[1]
local np_l_p10 = l_CI_np[2]
local np_u_p10 = u_CI_np[2]

import excel "${raw}\doing-economics-datafile-working-in-excel-project-2.xlsx", ///
    clear firstrow sheet("Fig_3")
gen wp = 0
drop if Period==.
save "${clean}\fig_3_a.dta", replace

import excel "${raw}\doing-economics-datafile-working-in-excel-project-2.xlsx", ///
    clear firstrow sheet("Fig_2A")
gen wp = 1
drop if Period==.
save "${clean}\fig_2A_a.dta", replace

use "${clean}\fig_2A_a.dta", clear
append using "${clean}\fig_3_a.dta"

keep if inlist(Period, 1, 10)

* 1. Renombrar ciudades con un mismo stub
rename Copenhagen      c1
rename Dnipropetrovsk  c2
rename Minsk           c3
rename StGallen        c4
rename Muscat          c5
rename Samara          c6
rename Zurich          c7
rename Boston          c8
rename Bonn            c9
rename Chengdu         c10
rename Seoul           c11
rename Riyadh          c12
rename Nottingham      c13
rename Athens          c14
rename Istanbul        c15
rename Melbourne       c16

* 2. Pasar de wide a long: una fila por ciudad
reshape long c, i(Period wp) j(city_id)

* 3. Recuperar nombres de ciudades
gen city = ""
replace city = "Copenhagen"     if city_id == 1
replace city = "Dnipropetrovsk" if city_id == 2
replace city = "Minsk"          if city_id == 3
replace city = "StGallen"       if city_id == 4
replace city = "Muscat"         if city_id == 5
replace city = "Samara"         if city_id == 6
replace city = "Zurich"         if city_id == 7
replace city = "Boston"         if city_id == 8
replace city = "Bonn"           if city_id == 9
replace city = "Chengdu"        if city_id == 10
replace city = "Seoul"          if city_id == 11
replace city = "Riyadh"         if city_id == 12
replace city = "Nottingham"     if city_id == 13
replace city = "Athens"         if city_id == 14
replace city = "Istanbul"       if city_id == 15
replace city = "Melbourne"      if city_id == 16

* 4. Pasar de long a wide para tener P1 y P10
reshape wide c, i(city_id city wp) j(Period)

* 5. Renombrar columnas finales
rename c1  P1
rename c10 P10

order city wp P1 P10

* 6. Clasificar si están dentro del IC
gen in_CI_P1  = .
gen in_CI_P10 = .

replace in_CI_P1  = (P1  >= `wp_l_p1'  & P1  <= `wp_u_p1')  if wp == 1
replace in_CI_P10 = (P10 >= `wp_l_p10' & P10 <= `wp_u_p10') if wp == 1

replace in_CI_P1  = (P1  >= `np_l_p1'  & P1  <= `np_u_p1')  if wp == 0
replace in_CI_P10 = (P10 >= `np_l_p10' & P10 <= `np_u_p10') if wp == 0

list city wp P1 in_CI_P1 P10 in_CI_P10, sepby(wp)

order city wp P1 in_CI_P1 P10 in_CI_P10

save "${clean}\CI_revision_P1_P10.dta", replace
export excel "${tables}\CI_revision_P1_P10.xlsx", replace firstrow(var)

restore

* 2.2.4 Calcular Min y Max P1 y P10

preserve

use "${clean}\CI_revision_P1_P10.dta", clear

gen exp = ""
replace exp = "Con castigo" if wp == 1
replace exp = "Sin castigo" if wp == 0

collapse ///
    (min) Min_P1  = P1  ///
    (max) Max_P1  = P1  ///
    (min) Min_P10 = P10 ///
    (max) Max_P10 = P10, by(exp)

order exp Min_P1 Max_P1 Min_P10 Max_P10
list

save "${clean}\min_max_revision_P1_P10.dta", replace
export excel "${tables}\min_max_revision_P1_P10.xlsx", replace firstrow(var)

restore

* 2.2.5 Tabla de Estadisticas Descriptivas

preserve

use "${clean}\CI_revision_P1_P10.dta", clear

gen exp = ""
replace exp = "Con castigo" if wp == 1
replace exp = "Sin castigo" if wp == 0

collapse ///
	(mean) mean_P1 = P1 ///
	(mean) mean_P10 = P10 ///
	(sd) sd_P1 = P1 ///
	(sd) sd_P10 = P10 ///
    (min) Min_P1  = P1  ///
    (max) Max_P1  = P1  ///
    (min) Min_P10 = P10 ///
    (max) Max_P10 = P10, by(exp)

rename mean_P1  Mean1
rename mean_P10 Mean10
rename sd_P1    SD1
rename sd_P10   SD10
rename Min_P1   Min1
rename Min_P10  Min10
rename Max_P1   Max1
rename Max_P10  Max10

reshape long Mean SD Min Max, i(exp) j(period)

gen Period = ""
replace Period = "P1"  if period == 1
replace Period = "P10" if period == 10

order exp Period Mean SD Min Max
sort exp period
drop period

list

save "${clean}\Descriptive_revision_P1_P10.dta", replace
export excel "${tables}\Descriptive_revision_P1_P10.xlsx", replace firstrow(var)

restore

* ------------------------------------------------------------------------
* Parte 2.3 ¿Cómo afectó el cambio de reglas del juego al comportamiento?
* ------------------------------------------------------------------------

* 2.3.1 Probabilidad según Diseño experimental

import excel "${raw}\Exp_Moneda.xlsx", firstrow clear

save "${clean}\Exp_Moneda.dta", replace

* 2.3.2 Calculo del ttest para diferencia de medias

use "${clean}\CI_revision_P1_P10.dta", clear

ttest P1, by(wp)

* 2.3.3 Calculo del ttest para diferencia de medias

use "${clean}\CI_revision_P1_P10.dta", clear

ttest P10, by(wp)




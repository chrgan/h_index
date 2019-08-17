program h_index_dev
	version 15.1
	syntax [, Runs(integer 1) 			/// repeat simulation r times
		n(integer 100) 					/// number of scientists
		INIT(string)						/// initial setup
		COauthors(real 5) 				/// average team size
		PERiods(integer 20) 				/// how often scientists collaborate
		SHarealpha(real .33)				/// share of initial papers where author is Alpha-Author
		DCitations(string) 				/// distribution of citations of new papers
		UPdate								/// update alpha author
		Peak(integer 3)					/// Peak of citations
		SPeed(real 2)						/// Kurtosis of distribution of citations
		BOOst(string)						/// Merton effect
		SUBgroups							/// Agents collaborate within subgropus
		EXChange(real 0)					/// Rate of exchange between subgroups
		ADVantage(real 1)					/// Factor by which citations of subgroup 2 exceed those of subgroup 1
		STrategic 							/// strategic selection of team members
		SELfcitation						/// cite papers with citations 1 below h
		DILigence(string) 				/// share of scientists who write papers at each round
		PLOTtimefunctionone(string)	/// Plot expected value of citations and time
		PLOTtimefunctiontwo				/// second option for plotting without twowayoptions
		CLEAR] 						// run simulation even if data in memory was not saved
	if "`clear'"=="" { // check for unsaved data
		quietly describe
		if r(changed)  { 
			error 4 
		}	
	}
	if `coauthors'<=1 { //average teamsize has to be >1
		di as error "average teamsize has to be greater than 1"
		exit
	}
	quietly {
		//parse options for initial setup
		*local init = subinstr("`init'", ",", "", 1)
		subprog_init `init' //FEHLERMELDUNG EINBAUEN, WENN DIE DISTRIBUTION FESTGElEGT WIRD BEI TYPE 2
		local inittype `s(inittype)'
		if "`inittype'"=="" {
			local inittype 1
		}
		local dpapers `s(dpapers)'
		local max_age_scientists `s(maxage)'
		local dil_init `s(dilinit)'
		//parse distribution options for papers
		local dpapers = subinstr("`dpapers'", ",", "", 1)
		subprog_distributions, `dpapers'
		local d_papers "`s(dist)'"
		local dpm `s(mean)'	
		local dpd `s(dispersion)'
		local dpp=`dpm'/(`dpm'*`dpd')
		local dpn=(`dpm'*`dpp')/(1-`dpp')
		//parse distribution options for citations of new papers
		local dcitations = subinstr("`dcitations'", ",", "", 1)
		subprog_distributions, `dcitations'
		local d_citations "`s(dist)'"
		local dcm `s(mean)'	
		local dcd `s(dispersion)'
		//additional locals for citations
		local alpha=`peak'/(((`speed'-1)/(`speed'+1))^(1/`speed'))
		local factor=`dcm'/(((`speed'/`alpha')*((`peak'/`alpha')^(`speed'-1)))/((1+(`peak'/`alpha')^`speed')^2))
		//parse options for diligence
		local diligence =subinstr("`diligence'", ",", "", 1)
		subprog_diligence, `diligence'
		local diligence_share `s(share)'
		local diligence_corr `s(correlation)'
		//parse option for merton effect
		subprog_merton, `boost'
		local size=`s(size)'
		if "`plottimefunctionone'" != "" {
			subprog_plottimefunction y=`factor'*(((`speed'/`alpha')*(x/`alpha')^(`speed'-1))/ ///
				((1+(x/`alpha')^`speed')^2)), ///
				range(0 `periods') xti("Period") yti("Expected value of citations") `plottimefunctionone'
			
		}
		if "`plottimefunctiontwo'" != "" {
			subprog_plottimefunction y=`factor'*(((`speed'/`alpha')*(x/`alpha')^(`speed'-1))/ ///
				((1+(x/`alpha')^`speed')^2)), ///
				range(0 `periods') xti("Period") yti("Expected value of citations")
			
		}
		//simulation starts here
		local obs=0 //needed to keep track of number of obs
		noi di "running simulation " _cont
		forvalues run=1/`runs' { //repeat simulation # times
			noi di "`run' " _cont //display number of run
			clear
			
			tempfile publ scient
			//create set of N scientists with k papers
			if `inittype'==1 {
				mata: scientists(`n',`d_papers',`dpm',`dpn',`dpp')
			}
			else if `inittype'==2 {
				mata: scientists2(`n',`max_age_scientists',`dil_init')
				bys scientist: egen no_paper_start=total(written)
				drop if written==0 & no_paper_start >0
				bys scientist: drop if no_paper_start==0 & _n>1
				g paper_id=_n
			}
			//no of papers can be 0, hence no age
			replace age_paper=.a if no_paper_start==0
			//make share of the papers alpha-paper
			g alpha=runiform()<`sharealpha'

			//citations
			g citations=0
			g topstart=0 //variable for number of top papers at beginning
			forvalues age=1/`max_age_scientists' {
				if `d_citations'==1 {
					g cit_`age'=rpoisson(`factor'*(((`speed'/`alpha')* ///
						((`age'/`alpha')^(`speed'-1)))/((1+(`age'/`alpha')^`speed')^2)))
					sum cit_`age', det
					g toppaper_`age'=cit_`age'>r(p90) & age_paper>=`age'
					bys scientist: egen top_`age'=total(toppaper_`age')
				}	
				else if `d_citations'==3 {
					g E_`age'=(`factor'*(((`speed'/`alpha')*((`age'/`alpha')^(`speed'-1)))/ ///
						((1+(`age'/`alpha')^`speed')^2)))
					g p_`age'=E_`age'/(E_`age'*`dcd')
					g n_`age'=(E_`age'*p_`age')/(1-p_`age')
					g cit_`age'=rnbinomial(n_`age',p_`age')
					sum cit_`age', det
					g toppaper_`age'=cit_`age'>r(p90) & age_paper>=`age'
					bys scientist: egen top_`age'=total(toppaper_`age')	
				}
			}		
			local i=1
			while `i'<=`max_age_scientists' {
				replace citations=citations+cit_`i' if age_paper>=`i'
				replace topstart=topstart+top_`i' 
				local ++i
			}
			drop cit_* top_* toppaper_*
			ren topstart top_0
			replace citations=.a if age_paper==.a
			capture drop E_* p_* n_*

			//calculate h
			gsort scientist -citations paper_id
			by scientist: g r=_n //order of papers by desc. no of citations
			//identify first paper where no of citations equals rank
			by scientist: g a=(citations>=r & citations[_n+1]<r[_n+1])
			//h-core-papers
			g core=r<=citations
			/*bring paper where number of citations equals rank on first place of each 
			scientist. if there is no such paper use paper with highest order number instead 
			(applies to scientists where every paper is cited more often than number of 
			papers or scientists without any citations*/
			gsort scientist -a -r
			//h-index is equal to rank of paper which is now on first place
			by scientist: g h_0=r[1]
			//replace h-index by zero for scientists without citations
			by scientist: egen number_cit=total(citations)
			replace h_0=0 if number_cit==0
			sum h_0
			g h_0_std=(h_0-r(mean))/r(sd)
			//calculate h-alpha
			g alpha_core=alpha==1 & core==1
			by scientist: egen h_alpha_0=total(alpha_core)
			replace h_alpha_0=0 if no_paper_start==0
			g maxh=h_0 if alpha==1 & age_paper <.
			replace maxh=h_0+runiformint(1,5) if maxh==. & age_paper<.
			//clean up, save
			drop r a number_cit core alpha_core			
			save `scient', replace
			//now let scientists collaborate
			forvalues year=1/`periods' {
				local prec_year=`year'-1 //preceding year
				sum paper_id
				local max_paper=r(max)
				//one row per scientist
				collapse h_0_std h_`prec_year' h_alpha_`prec_year', by(scientist)
				//select scientists who collaborate, see (1)
				if `diligence_share'<1 {
					g select_var=`diligence_corr'*h_0_std+sqrt(1-`diligence_corr'^2)*rnormal()
					local diligence_share_100=100-(`diligence_share'*100)
					centile select_var, centile(`diligence_share_100')
					keep if select_var>r(c_1)
					drop select_var
				}
				mark written //necessary for self citations
				//number of teams depends on desired average team size
				local number_of_teams=_N/(`coauthors')
				
				//strategic selection of team members?
				if "`subgroups'" == "" {
					if "`strategic'" != "" {
						gsort -h_`prec_year'
						local number_of_teams_round=round(`number_of_teams')
						g paper_id = _n in 1/`number_of_teams_round'
						replace paper_id=runiformint(1,`number_of_teams') if paper_id==.
					}
					else {
						g paper_id=runiformint(1,`number_of_teams') //team-number
					}
				}
				else if "`subgroups'" != "" {
					local half=_N/2
					g half=0 in 1/`half'
					recode half (.=1)
					recode half (0=1) (1=0) if runiform()<`exchange'
					if "`strategic'" != "" {
						gsort half -h_`prec_year'
						local number_of_teams_round_half=round((`number_of_teams')/2)
						g paper_id = _n in 1/`number_of_teams_round_half'
						local lower=`number_of_teams_round_half'+1
						replace paper_id=runiformint(1,`number_of_teams_round_half') in `lower'/`half'
						local lower=`half'+1
						local upper=`half'+`number_of_teams_round_half'
						replace paper_id=_n-`half'+`number_of_teams_round_half' in `lower'/`upper'
						replace paper_id=runiformint(`number_of_teams_round_half'+1,`number_of_teams') if paper_id==.
					}				
					else {
						g paper_id=runiformint(1,(`number_of_teams'/2)) if half==0 //team-number
						replace paper_id=runiformint(((`number_of_teams'/2)+1),`number_of_teams') if half==1
					}
				}			
				replace paper_id=paper_id+`max_paper'
				//save collaboration, add new papers to scientists-file
				save `publ', replace
				use `scient', clear
				if "`subgroups'" != "" {
					append using `publ', keep(scientist h_0_std paper_id written half)
				}
				else {
					append using `publ', keep(scientist h_0_std paper_id written)
				}
				replace age_paper=age_paper+1 if age_paper!=.a
				replace age_paper=1 if age_paper==.
				replace citations=0 if citations==.
				sort scientist h_`prec_year'
				by scientist: replace h_`prec_year'=h_`prec_year'[1]
				sort paper_id scientist
				by paper_id: egen maxh2=max(h_`prec_year') //identify alpha-author of each team
				replace maxh=maxh2 if maxh==. & citations!=.a
				replace alpha=h_`prec_year'==maxh if alpha==.
				//new citations for papers
				if (`d_citations'==1) {
					if "`subgroups'" == "" {
						replace citations=citations+rpoisson(`factor'*(((`speed'/`alpha')* ///
							((age_paper/`alpha')^(`speed'-1)))/((1+(age_paper/`alpha')^`speed')^2))) if age_paper!=.a
					} 
					else if "`subgroups'" != "" {
						replace citations=citations+(rpoisson(`factor'*(((`speed'/`alpha')* ///
							((age_paper/`alpha')^(`speed'-1)))/((1+(age_paper/`alpha')^`speed')^2)))) if age_paper!=.a  & half != 1
						replace citations=citations+(rpoisson(`factor'*(((`speed'/`alpha')* ///
							((age_paper/`alpha')^(`speed'-1)))/((1+(age_paper/`alpha')^`speed')^2))))*`advantage' if age_paper!=.a  & half == 1
					}
				}

				else if (`d_citations'==3) {
					g E=(`factor'*(((`speed'/`alpha')*((age_paper/`alpha')^(`speed'-1)))/ ///
						((1+(age_paper/`alpha')^`speed')^2)))
					g p=E/(E*`dcd')
					g n=(E*p)/(1-p)
					if "`subgroups'" == "" {
						replace citations = citations+rnbinomial(n,p) if age_paper!=.a
					}
					else if "`subgroups'" != "" {
						replace citations = citations+rnbinomial(n,p) if age_paper!=.a & half != 1
						replace citations = citations+rnbinomial(n,p)*`advantage' if age_paper!=.a & half == 1
					}
				}

				sort paper_id, stable
				by paper_id: replace citations=citations[1]
				if "`boost'"!="" {
					replace citations=citations+round(maxh*`size') if citations<.
				}
				if "`selfcitation'"!="" {
					sort scientist written
					by scientist: replace written=written[1]
					replace citations=citations+1 if ///
						(citations==h_`prec_year'-1 | citations==h_`prec_year'-2) & written==1
					gsort paper_id -citations
					by paper_id: replace citations=citations[1]
				}
				drop written
				capture drop E p n
				//count top 10 papers		
				if "`subgroups'" == "" {
					sum cit, det
					g toppaper=cit>r(p90)
					bys scientist: egen top_`year'=total(toppaper)
					drop toppaper
				}
				else if "`subgroups'" != "" {
					sum cit if half==0, det
					g toppaper=cit>r(p90) & half==0
					tab toppaper
					sum cit if half==1, det
					replace toppaper=1 if cit>r(p90) & half==1
					bys scientist: egen top_`year'=total(toppaper)
					drop toppaper
				}
				
				//calculate new h-index
				gsort scientist -citations paper_id
				by scientist: g r=_n
				by scientist: g a=(citations>=r & citations[_n+1]<r[_n+1])
				g core=r<=citations
				gsort scientist -a -r
				by scientist: g h_`year'=r[1]
				by scientist: egen number_cit=total(citations)
				replace h_`year'=0 if number_cit==0
				g alpha_core=alpha==1 & core==1
				by scientist: egen h_alpha_`year'=total(alpha_core)
				drop r a number_cit core alpha_core
				if "`update'"!="" { //reset maxh and alpha to missing
											//if alpha author is updated every period
					replace maxh=. if h_alpha_0==.
					replace alpha=. if h_alpha_0==.
				}
				drop maxh2
				save `scient', replace
			}
			g run=`run'
			putmata run`run'=(_all), replace //store data of run in mata
			local obs=`obs'+_N
		}
		//combine data into one matrix and store it in stata
		des
		local vars= r(k)
		mata: final_data=J(`obs',`vars',.)
		mata: lower=1
		mata: upper=rows(run1)
		forvalues k=1/`runs' {
			local l=`k'+1
			mata: final_data[|lower,1 \ upper,`vars'|]=run`k'[|1,1 \ rows(run`k'),`vars'|]
			if `k'<`runs' {
				mata: lower=lower+rows(run`k')
				mata: upper=upper+rows(run`l')
			}
		}
		mata: names=st_varname((1..`vars'))
		clear
		mata: st_addvar("float",names)
		mata: st_addobs(rows(final_data))
		mata: st_store(.,names,final_data)
		//one row per scientist
		drop citations alpha h_0_std
		if `inittype'==1 {
			collapse no_paper_start h_* top_*, by(scientist run)
		}
		else if `inittype'==2 {
			collapse age_scientist_start=age_scientist no_paper_start h_* top_*, by(scientist run)
		}
		//cumulate top papers over periods
		forvalues p=1/`periods' {
			local p0=`p'-1
			replace top_`p'=top_`p'+top_`p0'
		}
		//compute top papers age standardized
		forvalues per=0/`periods' {
			g top_`per'_std=top_`per'/(age_scientist_start+`per')
		}
		//compute m
		forvalues per=0/`periods' {
			g m_`per'=h_`per'/(age_scientist_start+`per')
		}
		//add variable indicating agent's subgroup
		if "`subgroups'" != "" {
			g subgroup=1 if scientist <= `n'/2
			recode subgroup (.=2)
		}
		compress
	}
end

//subroutines to parse suboptions, see (2)

program subprog_distributions, sclass
	syntax [, POIsson NEGBin ///
		Mean(integer 2) Dispersion(real 1.1)]
	if (("`poisson'"!="")+("`negbin'"!=""))>1 {
		di as err "too many distributions specified"
		error 197
	}
	if ("`negbin'"!="" & (`dispersion'<=1)) {
		di as err "dispersion has to be greater than 1"
		error 197
	}
	else if ((("`poisson'"!="")+("`negbin'"!=""))==0) | ///
		("`poisson'" != "") {
			local dist=1
	}
	else if ("`negbin'" != "") {
		local dist=3
	}
	sreturn local dist "`dist'"
	sreturn local mean `mean'
	sreturn local dispersion `dispersion'
end

program subprog_init, sclass
	syntax [anything] [, DPapers(string) MAXAge(integer 5) DILINit(real .8)]
	sreturn local inittype `anything'
	sreturn local dpapers "`dpapers'"
	sreturn local maxage `maxage'
	sreturn local dilinit `dilinit'
end

program subprog_diligence, sclass
	syntax [, SHare(real 1) Correlation(real 0)]
	if (`share'<0 | `share'>1 | `correlation'<0 | `correlation'>1) {
		di as err "share and correlation have to be between 0 and 1"
		error 197
	}
	sreturn local share `share'
	sreturn local correlation `correlation'
end

program subprog_merton, sclass
	syntax [, SIze(real .1)]
	sreturn local size `size'
end

program subprog_plottimefunction
	syntax anything(equalok) [, * ]
	twoway function `anything', `options'
end
	

//mata function for initial setup of scientists
version 15.1
mata:
void function scientists(real scalar n, real scalar d_papers, real scalar mdp,
	real scalar dpn, real scalar dpp)
{
	//create N scientists and number them
	S=J(1,1,1::n)
	//random number of papers per scientist
	if (d_papers==1) {
		P=rpoisson(n,1,mdp) //poisson distribution
	}
	else if (d_papers==3) {
		P=rnbinomial(n,1,dpn,dpp) //negative binomial distribution
	}
	//expand scientists by their number of papers
	S=S,P,J(rows(S),2,.)
	_mm_expand(S,P,1,1)
	//paper id, random age of papers
	for (i=1; i<=rows(S); ++i) {
		S[i,(cols(S)-1)]=i
		S[i,cols(S)]=runiformint(1,1,1,S[i,2])
	}
	//put to stata
	st_addvar("float", ("scientist","no_paper_start","paper_id","age_paper"))
	st_addobs(rows(S))
	st_store(.,.,S)
}

void function scientists2(real scalar n, real scalar max_age_scientists,
	real scalar dil_init)
{
	//create N scientists with random age
	S=J(1,1,1::n),runiformint(n,1,1,max_age_scientists),J(n,1,1)
	_mm_expand(S,S[.,2],1,1)
	for (i=2; i<=rows(S); i++) {
		if (S[i,1]==S[(i-1),1]) S[i,3]=S[(i-1),3]+1
	}
	S=S,(runiform(rows(S),1):<=dil_init)
	st_addvar("float", ("scientist","age_scientist","age_paper","written"))
	st_addobs(rows(S))
	st_store(.,.,S)
}
end


/*
(1) https://www.statalist.org/forums/forum/general-stata-discussion/general/
565527-creating-a-variable-with-a-known-correlation-with-existing-variables

(2) https://www.statalist.org/forums/forum/general-stata-discussion/general/
1315697-syntax-for-options-within-options

todo

- Produktivitätsvariable
- Agenten schon im Startwelt in Subgruppen aufteilen
- Optionen für zu speichernde (besser: zu berechnende) Variablen
- Top-Paper auf Paper-Alter standardisieren
(help-file aktualisieren)



program h_index
	version 15.1
	syntax [, Runs(integer 1) 			/// repeat simulation r times
		n(integer 100) 					/// number of scientists
		COauthors(real 5) 				/// average team size
		PERiods(integer 20) 				/// how often scientists collaborate
		DPapers(string) 					/// initial distribution of papers
		SHarealpha(real .33)				/// share of initial papers where author is Alpha-Author
		DCitations(string) 				/// distribution of citations of new papers
		UPdate								/// update alpha author
		Peak(integer 3)					/// Peak of citations
		SPeed(real 2)						/// Kurtosis of distribution of citations
		BOOst(string)						/// Merton effect
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
			mata: scientists(`n',`d_papers',`dpm',`dpn',`dpp',`sharealpha')
			//no of papers can be 0, hence no age
			replace age_paper=.a if no_paper_start==0
			//citations
			g citations=0
			forvalues age=1/5 {
				if `d_citations'==1 {
					g cit_`age'=rpoisson(`factor'*(((`speed'/`alpha')* ///
						((`age'/`alpha')^(`speed'-1)))/((1+(`age'/`alpha')^`speed')^2)))
				}	
				else if `d_citations'==3 {
					g p_`age'=(`factor'*(((`speed'/`alpha')*((`age'/`alpha')^(`speed'-1)))/ ///
						((1+(`age'/`alpha')^`speed')^2)))/((`factor'*(((`speed'/`alpha')*((`age'/`alpha')^(`speed'-1)))/ ///
						((1+(`age'/`alpha')^`speed')^2)))*`dcd')
					g n_`age'=((`factor'*(((`speed'/`alpha')*((`age'/`alpha')^(`speed'-1)))/ ///
						((1+(`age'/`alpha')^`speed')^2)))*p_`age')/(1-p_`age')
					g cit_`age'=rnbinomial(n_`age',p_`age')
				}
			}
			local i=1
			while `i'<=5 {
				replace citations=citations+cit_`i' if age_paper>=`i'
				local ++i
			}
			drop cit_*
			replace citations=.a if age_paper==.a
			capture drop p_* n_*
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
				if "`strategic'" != "" {
					gsort -h_`prec_year'
					g paper_id = _n in 1/`number_of_teams'
					replace paper_id=runiformint(1,`number_of_teams') if paper_id==.
				}
				else {
					g paper_id=runiformint(1,`number_of_teams') //team-number
				}
				replace paper_id=paper_id+`max_paper'
				//save collaboration, add new papers to scientists-file
				save `publ', replace
				use `scient', clear
				append using `publ', keep(scientist paper_id written )
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
					replace citations=citations+rpoisson(`factor'*(((`speed'/`alpha')* ///
						((age_paper/`alpha')^(`speed'-1)))/((1+(age_paper/`alpha')^`speed')^2))) if age_paper!=.a
				}

				else if (`d_citations'==3) {
					g p=(`factor'*(((`speed'/`alpha')*((age_paper/`alpha')^(`speed'-1)))/ ///
						((1+(age_paper/`alpha')^`speed')^2)))/((`factor'*(((`speed'/`alpha')*((age_paper/`alpha')^(`speed'-1)))/ ///
						((1+(age_paper/`alpha')^`speed')^2)))*`dcd')
					g n=((`factor'*(((`speed'/`alpha')*((age_paper/`alpha')^(`speed'-1)))/ ///
						((1+(age_paper/`alpha')^`speed')^2)))*p)/(1-p)
					replace citations = citations+rnbinomial(n,p) if age_paper!=.a
					drop p n
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
		collapse no_paper_start h_*, by(scientist run)
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
	real scalar dpn, real scalar dpp, real scalar salpha)
{
	//create N scientists, random number of papers per scientist, number scientists
	if (d_papers==1) { //poisson distribution
		S=J(1,1,1::n),rpoisson(n,1,mdp)
	}
	else if (d_papers==3) { //negative binomial distribution
		S=J(1,1,1::n),rnbinomial(n,1,dpn,dpp)
	}
	//expand scientists by their number of papers
	_mm_expand(S,S[.,2],1,1)
	//paper id ,random age of papers, alpha papers
	S=S,J(1,1,1::rows(S)),runiformint(rows(S),1,1,5),(runiform(rows(S),1):<salpha)
	//put to stata
	st_addvar("float", ("scientist","no_paper_start","paper_id","age_paper","alpha"))
	st_addobs(rows(S))
	st_store(.,.,S)
}
end


/*
(1) https://www.statalist.org/forums/forum/general-stata-discussion/general/
565527-creating-a-variable-with-a-known-correlation-with-existing-variables

(2) https://www.statalist.org/forums/forum/general-stata-discussion/general/
1315697-syntax-for-options-within-options




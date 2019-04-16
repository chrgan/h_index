{smcl}
{* *! version 0.3  05apr2019}{...}
{viewerjumpto "Syntax" "h_index##syntax"}{...}
{viewerjumpto "Description" "h_index##description"}{...}
{viewerjumpto "Options" "h_index##options"}{...}
{viewerjumpto "Examples" "h_index##examples"}{...}
{viewerjumpto "References" "h_index##references"}{...}
{viewerjumpto "Author" "h_index##author"}{...}
{p2colset 1 15 17 2}{...}
{p2col:{bf:h_index} {hline 2}}Simulate the effect of publishing, being cited, 
and (strategic) collaborating on the development of h-index and h-alpha values for a specified set of agents.{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:h_index}
[{cmd:,} {it:options}]

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt r:uns(#)}}repeat simulation # times{p_end}
{synopt :{opt n(#)}}create # agents per simulation{p_end}
{synopt :{opt co:authors(#)}}average team size of collaborating co-authors{p_end}
{synopt :{opt per:iods(#)}}let agents collaborate across {it:p} periods {p_end}
{synopt :{opt dp:apers(distribution_options)}}initial distribution of papers which have been published by agents (before simulation starts){p_end}
{synopt :{opt sh:arealpha(#)}}share of previously published papers where agents are 
alpha-authors.{p_end}
{synopt :{opt dc:itations(distribution_options)}}distribution of citations papers receive in simulation{p_end}
{synopt :{opt p:eak(#)}}period when number of citations reaches its maximum{p_end}
{synopt :{opt sp:eed(#)}}steepness of period function{p_end}
{synopt :{cmdab:boo:st}([{cmd:}{it:{ul:si}ze(#)}])}boost of citations{it:#}{p_end}
{synopt :{opt st:rategic}}let agents strategically select co-authors{p_end}
{synopt :{opt dil:igence(diligence_options)}}share of agents publishing papers each period{p_end}
{synopt :{opt plot:timefunction}}plot expected values of citations as function of period{p_end}
{synopt :{opt clear}}overwrite current data in memory{p_end}

{syntab:distribution_options}
{synopt :{cmdab:poi:sson} [{cmd:,} {it:{ul:m}ean(#)}]}Poisson with mean {it:#}{p_end}
{synopt :{cmdab:negb:in} [{cmd:,} {it:{ul:m}ean(#) {ul:d}ispersion(#)}]}negative 
binomial with mean {it:#} and dispersion {it:#} {p_end}

{syntab:diligence_options}
{synopt :[{cmd:}{it:{ul:sh}are(#)} {it:{ul:c}orrelation(#)}]}share of agents publishing papers and
correlation between probability of publishing with initial h-index values{p_end}

{marker description}{...}
{title:Description}

{pstd}
{opt h_index} simulates agents publishing papers without or with co-authors across t 
periods with actions. For each period, h-index (Hirsch, 2005) and h-alpha-index 
(Hirsch, 2019) values for every agent are calculated based on the number of 
citations each paper receives. In each period, the simulation is repeated r times 
to enhance the robustness of the results.

{pstd}
h_index produces a dataset containing the following variables:

{synoptset 20 tabbed}{...}
{synopt:{cmd:agent}}consecutive number of agents per simulation{p_end}
{synopt:{cmd:run}}consecutive number of runs{p_end}
{synopt:{cmd:no_paper_start}}number of previously published papers per agent{p_end}
{synopt:{cmd:h_0}}h-index of each agent before acting starts{p_end}
{synopt:{cmd:h_alpha_0}}h-alpha-index of each agent before acting starts{p_end}
{synopt:{cmd:h_*}}h-index of each agent per period{p_end}
{synopt:{cmd:h_alpha_*}}h-alpha-index of each agent per period{p_end}

{pstd}
If one is interested in reproducing results, one should first set the
random-number seed; see {manhelp set_seed R:set seed}.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt runs(#)} specifies how often the simulation is repeated. Default is 1. 

{phang}
{opt n(#)} specifies how many agents per simulation act. Default is 100.

{phang}
{opt coauthors(#)} specifies the average number of co-authors publishing papers. Default is 5. 

{phang}
{opt periods(#)} specifies that agents collaborate across {it:t} periods. Default is 20.

{phang}
{opt dpapers(distribution_options)} every agent is assumed to have published {it:p} 
papers before the simulation starts. {opt dpapers()} specifies the distribution of the number of 
previously published papers.

{phang}
{opt sharealpha(#)} specifies the share of previously published papers where the agent
is alpha-author. The alpha-author is the agent with the highest h-index among co-authors. Default is .33.

{phang}
{opt dcitations(distribution_options)} specifies the distribution of citations 
papers receive. The expected value of citations is assumed to follow a log-logistic 
function of time. {opt dcitations()} specifies the expected value of the
distribution of citations at the time when citations reach their maximum 
(see {opt peak()}). Before and after the peak, the expected value of the citation distribution is always lower.

{phang}
{opt peak(#)} specifies when the expected value of the citation distribution 
reaches its maximum. Default is 3.

{phang}
{opt speed(#)} specifies the steepness of the log-logistic time function of the expected
citations values. The higher {it:speed(#)}, the steeper the function. Default is 2. 

{phang}
{opt boost}([{cmd:}{it:{ul:si}ze(#)}]) specifies a "boost" effect: 
papers of agents with higher h-index values are cited more frequently than papers of agents with lower h-index values. For every additional h 
point of an agent's paper who has the highest h-index among all agents, citations 
are increased by the number specified with {it:size(#)}, rounded to the next 
integer. For example, consider a single paper where the highest h-index of its agents is 11.
If one specifies {it:size(#)} to be .5, this paper receives additional 
{it:round(11*.5) = 6} citations. Default for size is .1.

{phang}
{opt strategic} by default, the collaborating agents are assigned to
co-authorships at random. By specifying {opt strategic}, agents with high h-index values avoid co-authorships
with agents who have equal or higher h-index values. They strategically select co-authors
to improve their h-alpha-index.

{phang}
{opt diligence(diligence_options)} by default, every agent is assigned to co-authorships
every period. By specifying {opt diligence()}, a lower share of agents publishing papers
can be set. The probability of publishing a paper in a given period is random by default, however, 
its correlation with the initial h-index can be set.

{phang}
{opt plottimefunction} produces a graph showing the expected citation values
as a function of periods as specified by {opt peak(#)} and {opt speed(#)}.

{phang}
{opt clear} forces h_index to run even though the dataset has changed since it was 
last saved.

{dlgtab:distribution_options}

{phang}
{opt poisson} [{cmd:,} {it:{ul:m}ean(#)}] Poisson distributin with mean {it:#}. 
See {help rpoisson()}. This is the default if no option is specified. Default for {it:mean} is 2.

{phang}
{opt negbin} [{cmd:,} {it:{ul:m}ean(#) {ul:d}ispersion(#)}] negative binomial distribution with parameters 
{it:mean(#)} and {it:dispersion(#)}. {it:mean()} is the expected value, 
{it:dispersion()} is a factor by which the variance exceeds the expected value. 
For example, if one specifies {cmd: negbin, mean(3) dispersion(2)}, the expected value is 3 and the variance is 6. The parameters {it:n} and {it:p} of 
{help rnbinomial()} are calculated from mean() and dispersion(). The default for 
{it:mean} is 2, the default for {it:dispersion} is 1.1. {it:dispersion(#)} must 
be greater than 1.

{dlgtab:diligence_options}

{phang}
    [{cmd:}{it:{ul:sh}are(#)} {it:{ul:c}orrelation(#)}] {it:share(#)} with {it:0<#<=1}
	 specifies the share of agents publishing a new paper each period. {it:correlation(#)}
	 with {it:0<#<=1} specifies the correlation between the probability of publishing a paper
	 with the initial h-index value. Thus, one can specify that agents with high 
	 initial h-index values are more productive in general. 
	 
{marker examples}{...}
{title:Examples}

    {hline}
    Let agents collaborate across 10 periods, repeat the simulation 10 times
{phang2}{cmd:. h_index, runs(10) periods(10)}

    {hline}
{pstd}Let 200 agents collaborate across 20 periods; repeat the simulation 10 times and compare
the h-alpha-index values of agents with low/high initial h-index values; make the results reproducible.{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. set seed 875777}{p_end}

{pstd}Run simulation{p_end}
{phang2}{cmd:. h_index, runs(10) n(200)}{p_end}

{pstd}Identify relative low/high h-values{p_end}
{phang2}{cmd:. summarize h_0, detail}{p_end}

{pstd}Some data management{p_end}
{phang2}{cmd:. preserve}{p_end}
{phang2}{cmd:. keep if h_0<2 | h_0>2}{p_end}
{phang2}{cmd:. generate high_h=h_0>2}{p_end}
{phang2}{cmd:. collapse h_alpha_*, by(high_h)}{p_end}
{phang2}{cmd:. xpose, clear}{p_end}
{phang2}{cmd:. drop in 1}{p_end}
{phang2}{cmd:. generate year=_n}{p_end}

{pstd}Create graph{p_end}
{phang2}{cmd:. twoway line v1 v2 year, legend(label(1 "Low initial h-index") label(2 "High initial h-index")) ytitle("Mean h_alpha value")}{p_end}

{pstd}Restore data{p_end}
{phang2}{cmd:. restore}{p_end}

    {hline}

{marker references}{...}
{title:References}

{pstd}
Hirsch, J. E. (2005). An index to quantify an individual's scientific research output. Proceedings of the National Academy of Sciences of the United States of America, 102(46), 16569-16572.{p_end}

{pstd}
Hirsch, J. E. (2019). Ha: An index to quantify an individual's scientific leadership. Scientometrics, 118(2), 673–686.{p_end}

{marker author}{...}
{title:Author}

{pstd}
Christian Ganser, LMU Munich, christian.ganser@lmu.de{p_end}

{smcl}
{* *! version 1.0 11feb2020}{...}
{viewerjumpto "Syntax" "h_index##syntax"}{...}
{viewerjumpto "Description" "h_index##description"}{...}
{viewerjumpto "Options" "h_index##options"}{...}
{viewerjumpto "Examples" "h_index##examples"}{...}
{viewerjumpto "References" "h_index##references"}{...}
{viewerjumpto "Author" "h_index##author"}{...}
{p2colset 1 15 17 2}{...}
{p2col:{bf:h_index} {hline 2}}Simulate the effect of publishing, being cited, 
and (strategic) collaboration on the development of the h-index and other 
bibliometric indicators (h-alpha, m-index, number of highly-cited papers) 
for a specified set of agents.{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:h_index}
[{cmd:,} {it:options}]

{synoptset 40 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt r:uns(#)}}repeat simulation # times{p_end}
{synopt :{opt n(#)}}create # agents per simulation{p_end}
{synopt :{opt init(init_options)}}initial setup{p_end}
{synopt :{opt co:authors(#)}}average number of collaborating agents (co-authors){p_end}
{synopt :{opt per:iods(#)}}let agents collaborate across {it:p} periods {p_end}
{synopt :{opt sh:arealpha(#)}}share of previously published papers where agents are 
alpha-authors.{p_end}
{synopt :{opt dc:itations(distribution_options)}}distribution of citations papers receive in simulation{p_end}
{synopt :{opt sub:groups(subgroup_options)}}let agents collaborate within two subgroups (1 and 2){p_end}
{synopt :{opt up:date}}update alpha-authors each period{p_end}
{synopt :{opt p:eak(#)}}period when number of citations reaches its maximum{p_end}
{synopt :{opt sp:eed(#)}}steepness of period function{p_end}
{synopt :{cmdab:boo:st}([{cmd:}{it:{ul:si}ze(#)}])}boost citations by cumulative advantage effects{p_end}
{synopt :{opt st:rategic}}let agents strategically select co-authors{p_end}
{synopt :{opt sel:fcitation}}let agents strategically cite their own papers{p_end}
{synopt :{cmdab:dil:igence}([{cmd:}{it:{ul:sh}are(#) {ul:c}orrelation(#)}])}share of agents publishing papers each period{p_end}
{synopt :{cmdab:plot:timefunction}[({it:{help twoway_options}})]}plot expected values of citations as a function of time{p_end}
{synopt :{opt g:enerate(variables)}}select indicators to generate (one or more of 
{opt top:papers} {opt m:} {opt h:} {opt ha:lpha}){p_end}
{synopt :{opt clear}}overwrite current data in memory{p_end}

{syntab:init_options}
{synopt :#}type of inititial setup, 1 or 2{p_end}
{synopt :{opt dp:apers(distribution_options)}}initial distribution of papers 
which have been published by agents{p_end}
{synopt :{opt maxa:ge}}maximum number of periods agents have published before
collaboration starts{p_end}
{synopt :{opt prod:uctivity(#)}}share of papers published by the 20% most productive
agents{p_end}

{syntab:distribution_options}
{synopt :{cmdab:poi:sson} [{cmd:,} {it:{ul:m}ean(#)}]}poisson with mean {it:#}{p_end}
{synopt :{cmdab:negb:in} [{cmd:,} {it:{ul:m}ean(#) {ul:d}ispersion(#)}]}negative 
binomial with mean {it:#} and dispersion {it:#} {p_end}

{syntab:subgroup_options}
{synopt :#}relative size of one of two subgroups{p_end}
{synopt :{opt exc:hange}}share of agents of each subgroup collaborating with 
agents of the other subgroup each period{p_end}
{synopt :{opt adv:antage}}specifies a factor by which citations of papers published
by agents of subgroup 2 exceed citations of papers published by subgroup 1.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{opt h_index} simulates agents publishing papers without or with co-authors across {it:t} 
periods with actions. For each period, the following bibliometric indicators can be 
calculated based on the number of citations each paper receives: h-index (Hirsch, 2005); 
m-index (i.e. h-index standardized by the time since the 
first publication of the author); h-alpha-index (Hirsch, 2019) and h-alpha-index standardized by 
the time since the first publication of the author (standardized h-alpha-index); the number of highly cited
papers written by an author and the number of highly cited papers standardized by time 
since first publication of the author (number of top-papers; these are papers belonging to the 10% most 
frequently cited papers in the dataset). The simulation is repeated {it:r} times 
to enhance the robustness of the results.

{pstd}
h_index produces a dataset containing the following variables (depending on specifications by the user):

{synoptset 20 tabbed}{...}
{synopt:{it:Basic variables}}{p_end}
{synopt:{cmd:scientist}}consecutive number of agents per simulation{p_end}
{synopt:{cmd:run}}consecutive number of runs{p_end}
{synopt:{cmd:age_scientist_start}}number of periods since each scientist started publishing before collaboration starts{p_end}
{synopt:{cmd:pubprob}}agent's probability of publishing in each period{p_end}
{synopt:{cmd:no_paper_start}}number of previously published papers per agent{p_end}
{synopt:{cmd:subgroup}}the subgroup each agent belongs to (only if {opt subgroup} is specified){p_end}

{p 6 6 2}
{it:Bibliometric indicators}{p_end}
{p 6 6 2}
The following variables have a suffix # indicating the period of
action. Suffix 0 indicates the respective indicator before collaboration starts
(i.e. after the initial setup), suffixes 1 to {it:T} indicate the respective
indicator for each period with action of each agent.{p_end}

{synopt:{cmd:h_#}}h-index{p_end}
{synopt:{cmd:h_alpha_#}}h-alpha-index{p_end}
{synopt:{cmd:h_alpha_std_#}}h-alpha-index standardized by the number of periods 
since the agent started publishing{p_end}
{synopt:{cmd:m_#}}m-index, which is the h-index standardized by the number of periods 
since the agent started publishing {p_end}
{synopt:{cmd:top_#}}number of highly cited papers published by an agent. A highly cited paper is defined as
belonging to the 10% most frequently cited papers. If a paper is a top paper in multiple
periods, it is counted multiple times.{p_end}
{synopt:{cmd:top_#_std}}number of highly cited papers published by an agent standardized 
by the number of periods since the agent started publishing{p_end}

{pstd}
If you are interested in reproducing results, you must first set the
random-number seed; see {manhelp set_seed R:set seed}. 
The package {net "describe moremata, from(http://fmwww.bc.edu/RePEc/bocode/m)":moremata} must be installed.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt runs(#)} specifies how often the simulation is repeated. The default is 1. 

{phang}
{opt n(#)} specifies how many agents per simulation act. The default is 100.

{phang}
{opt init(init_options)} specifies the type of the initial setup. If type 1
is specified, the default, every agent is assumed to have published p papers before the 
simulation of collaboration starts. It is assumed that each paper has been published
1 to 5 periods ago and the distribution of the number of 
previously published papers can be specified. By selecting type 2, it is possible 
to specify how many periods ago agents have started to publish and the share of 
papers published by the most productive agents. This makes it possible to analyze 
the influence of seniority, for example.

{phang}
{opt coauthors(#)} specifies the average number of co-authors publishing papers. The default is 5. 

{phang}
{opt periods(#)} specifies that agents collaborate across {it:t} periods. The default is 20.

{phang}
{opt sharealpha(#)} specifies the share of previously published papers where the agent
is the alpha-author. The alpha-author is the agent with the highest h-index among the co-authors. The default is .33.

{phang}
{opt dcitations(distribution_options)} specifies the distribution of citations 
papers receive. The expected value of citations is assumed to follow a log-logistic 
time function. {opt dcitations()} specifies the expected value of the citation
distribution at the time when citations reach their maximum 
(see {opt peak()}). Before and after the peak, the expected value of the citation distribution is always lower.

{phang}
{opt subgroups(subgroup_options)} specifies that agents belong to two subgroups. For
example, imagine a research institute where scientists publish in two adjacent 
subdisciplines.

{phang}
{opt update} specifies that the alpha-author of new papers is determined 
every period based on the current h-index-values of its authors. Without this option,
the alpha-author is determined when the paper has been published and is held constant from then on.

{phang}
{opt peak(#)} specifies when the expected value of the citation distribution 
reaches its maximum. The default is 3.

{phang}
{opt speed(#)} specifies the steepness of the log-logistic time function of the expected
citation values. The higher {it:speed(#)}, the steeper the function. The default is 2. 

{phang}
{opt boost}([{cmd:}{it:{ul:si}ze(#)}]) specifies a "boost" effect: 
papers of agents with higher h-index values are cited more frequently than papers of 
agents with lower h-index values (heading: cumulative advantage). For every additional h 
point of an agent's papers who has the highest h-index among all agents, citations 
are increased by the number specified with {it:size(#)}, rounded to the next 
integer. For example, suppose a single paper where the highest h-index of its agents is 11.
If one specifies {it:size(#)} to be .5, this paper receives additional 
{it:round(11*.5) = 6} citations. The default for size is .1.

{phang}
{opt strategic} By default, the collaborating agents are assigned to
co-authorships at random. By specifying {opt strategic}, agents with high h-index values avoid co-authorships
with agents who have equal or higher h-index values. They strategically select co-authors
to improve their h-alpha-index.

{phang}
{opt selfcitation} When this option is set, a paper gets one additional citation if
at least one of its authors has an h-index which exceeds the number of previous
citations of the paper by one or two. This reflects agents strategically citing 
their own papers with citations just below their h-index to accelerate the growth of
their h-index.

{phang}
{opt diligence}([{cmd:}{it:{ul:sh}are(#) {ul:c}orrelation(#)}]) By default, every agent co-publishes with other agents
every period. By specifying {opt diligence()}, a lower share of agents publishing papers
can be set. The probability of publishing a paper in a given period is at random by default, however, 
its correlation with the initial h-index can be set. {it:share(#)} with {it:0<#<=1}
	 specifies the share of agents publishing a new paper every period. {it:correlation(#)}
	 with {it:0<#<=1} specifies the correlation between the probability of publishing a paper
	 with the initial h-index value. Thus, one can specify that agents with high 
	 initial h-index values are more productive in general. This option is only
	 available with {opt init(1)}. With {opt init(2)}, each agent is assumed
	 to have a probability of publishing which is constant over time.

{phang}
{opt plottimefunction} produces a graph showing the expected citation values
as a function of periods as specified by {opt peak(#)} and {opt speed(#)}. If the user 
specifies {opt plottimefunction} (without brackets), the x-axis will range from 0 to 
the number of periods specified by {opt periods(#)} and preset titles for the 
axes will be used. The user can alter this by specifying {opt plottimefunction(twoway_options)}, 
which allows for all {help twoway_options}. When using {opt plottimefunction(twoway_options)},
at least one twoway option has to be specified, otherwise no graph will appear. Also see {help twoway function}.

{phang}
{opt generate(variables)} specifies the indicators to be computed. One or more of the 
following indicators may be specified: {opt top:papers} (number of highly cited papers and
number of highly cited papers standardized), {opt m:} (m-index), {opt h:} (h-index),
 {opt ha:lpha} (h-alpha-index and h-alpha-index standardized) (see 
 {help h_index_dev##description:description} for details). The default is to
 generate h-index and h-alpha-index.

{phang}
{opt clear} forces h_index to run even though the dataset has changed since it was 
last saved.

{dlgtab:init_options}

{phang}
{opt #} specifies the type of the initial setup, see above. The default is type 1.

{phang}
{opt dpapers(distribution_options)} is for use with type 1 only. Every agent is assumed to have published {it:p} 
papers before the simulation starts. {opt dpapers()} specifies the distribution of the number of 
previously published papers. This suboption is also available as an option,
i.e. {cmd:h_index, init(1, dpapers(...))} is equivalent to {cmd: h_index, dpapers(...)}. 
When using the latter, init() cannot be specified. 

{phang}
{opt maxage(#)} specifies how many periods ago agents have started to publish at most. The default is 5.

{phang}
{opt productivity(#)} specifies the share of papers published by the 20% most 
productive agents as a percentage. This share is kept constant throughout the periods
in which agents collaborate. The default is 80.

{phang}
For example, if the user specifies {cmd: init(2, maxage(20) productivity(70))}, agents have started
publishing 1 to 20 periods ago and the 20% most productive agents publish 70% of all papers on average.

{dlgtab:distribution_options}

{phang}
{opt poisson} [{cmd:,} {it:{ul:m}ean(#)}] Poisson distribution with mean {it:#}. 
See {help rpoisson()}. This distribution is the default if no option is specified. The default for {it:mean} is 2.

{phang}
{opt negbin} [{cmd:,} {it:{ul:m}ean(#) {ul:d}ispersion(#)}] negative binomial distribution with parameters 
{it:mean(#)} and {it:dispersion(#)}. {it:mean(#)} is the expected value, 
{it:dispersion(#)} is a factor by which the variance exceeds the expected value. 
For example, if the user specifies {cmd: negbin, mean(3) dispersion(2)}, the expected value is 3 and the variance is 6. The parameters {it:n} and {it:p} of 
{help rnbinomial()} are calculated from {it:mean(#)} and {it:dispersion(#)}. The default for 
{it:mean} is 2, the default for {it:dispersion} is 1.1. {it:dispersion(#)} must 
be greater than 1.

{dlgtab:subgroup_options}

{phang}
{opt #} specifies that agents belong to two subgroups and a share of # agents
belongs to the first of the two groups.

{phang}
{opt exchange(#)} specifies the share of agents publishing (alone or in collaboration)
with the other subgroup in each period. For example, when specifying 
{opt exchange(.1)}, 10% of each subgroup join the other subgroup each period. The default
is 0, i.e. agents do not publish with the other subgroup in collaboration.

{phang}
{opt advantage(#)} specifies a factor by which citations of papers published by agents 
of subgroup 2 exceed those of papers published by subgroup 1. This option is intended
to reflect subdisciplines with different citation levels. The default is 1, which 
reflects equal citation levels.

{phang}
For example, if one specifies {cmd: subgroups(.2, advantage(1.5) exchange(.1))},
20 percent of all agents belong to subgroup 1. The papers published by the agents
of subgroup 2 (consisting of the other 80% of the agents) receive 1.5 times the
citations of the papers published by agents of subgroup 1. However, in each period
10%, of the agents of subgroup 1 collaborate with agents of subgroup 2 and 
vice versa.

{marker examples}{...}
{title:Examples}

    {hline}
    Let agents collaborate across 10 periods, repeat the simulation 10 times
{phang2}{cmd:. h_index, runs(10) periods(10)}

    {hline}
{pstd}Let 200 agents collaborate across 20 periods. Repeat the simulation 10 times and compare
the h-alpha-index values of agents with low/high initial h-index values. Make the results reproducible.{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. set seed 875777}{p_end}

{pstd}Run simulation{p_end}
{phang2}{cmd:. h_index, runs(10) n(200)}{p_end}

{pstd}Identify relative low/high h-index-values{p_end}
{phang2}{cmd:. summarize h_0, detail}{p_end}

{pstd}Data management{p_end}
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
Bornmann, L. In press. Bibliometric indicators – methods for measuring science. In: Williams, R., ed. Encyclopedia of Research methods. Thousand Oaks, CA, USA: Sage. 

{pstd}
Bornmann, L., C. Ganser, A. Tekles, and L. Leydesdorff. In press. Does the hα index 
reinforce the Matthew effect in science? The introduction of agent-based simulations into scientometrics. 
Quantitative Science Studies.

{pstd}
Hirsch, J. E. (2005). An index to quantify an individual's scientific research output. Proceedings of the National Academy of Sciences of the United States of America, 102(46), 16569-16572.{p_end}

{pstd}
Hirsch, J. E. (2019). Ha: An index to quantify an individual's scientific leadership. Scientometrics, 118(2), 673–686.{p_end}

{pstd}
Jann, B. 2005. moremata: Stata module (Mata) to provide various functions.
Available from http://ideas.repec.org/c/boc/bocode/s455001.html.{p_end}


{marker author}{...}
{title:Author}

{pstd}
Christian Ganser(*), christian.ganser@lmu.de, in collaboration with 
Lutz Bornmann(+) and Alexander Tekles(*,+){p_end}

{pstd}
*Ludwig-Maximilians-Universität Munich, Department of Sociology{break}
+Division for Science and Innovation Studies, Administrative Headquarters of the Max Planck Society{p_end}

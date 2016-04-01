#!/bin/bash

#set -x

usage()
{
cat <<EOF
${txtcyn}

***CREATED BY Chen Tong (chentong_biology@163.com)***

Usage:

$0 options${txtrst}

${bldblu}Function${txtrst}:

This script is used to do heatmap using package pheatmap.

The parameters for logical variable are either TRUE or FALSE.

${txtbld}OPTIONS${txtrst}:
	-f	Data file (with header line, the first column is the
 		rowname, tab seperated. Colnames must be unique unless you
		know what you are doing.)${bldred}[NECESSARY]${txtrst}
	-t	Title of picture[${txtred}Default empty title${txtrst}]
		[Scatter plot of horizontal and vertical variable]
	-a	Display xtics. ${bldred}[Default TRUE]${txtrst}
	-A	Rotation angle for x-axis value(anti clockwise)
		${bldred}[Default 0, unused]${txtrst}
	-b	Display ytics. ${bldred}[Default TRUE]${txtrst}
	-H	Hieratical cluster for columns.
		${bldred}Default FALSE, accept TRUE${txtrst}
	-R	Hieratical cluster for rows.
		${bldred}Default TRUE, accept FALSE${txtrst}
	-c	Clustering method, Default "complete". 
		Accept "ward.D", "ward.D2","single", "average" (=UPGMA), 
		"mcquitty" (=WPGMA), "median" (=WPGMC) or "centroid" (=UPGMC)
	-D	Clustering the distance for rows.
		${bldred}Default 'correlation', accept 'euclidean', 
		"manhattan", "maximum", "canberra", "binary", "minkowski". ${txtrst}
	-I	Clustering the distance for cols.
		${bldred}Default 'correlation', accept 'euclidean', 
		"manhattan", "maximum", "canberra", "binary", "minkowski". ${txtrst}
	-L	First get log-value, then do other analysis.
		Accept an R function log2 or log10. 
		${bldred}[Default FALSE]${txtrst}
	-d	Scale the data or not for clustering and visualization.
		[Default 'none' means no scale, accept 'row', 'column' to 
		scale by row or column.]
	-k	Aggregate the rows using kmeans clustering. 
		This is advisable if number of rows is so big that R cannot 
		handle their hierarchical clustering anymore, roughly more than 1000.
		Instead of showing all the rows separately one can cluster the
		rows in advance and show only the cluster centers. The number
		of clusters can be tuned here.
		[${txtred}Default 'NA' which means no
		cluster, other positive interger is accepted for executing
		kmeans cluster, also the parameter represents the number of
		expected clusters.${txtrst}]
	-u	The width of output picture.[${txtred}Default 20${txtrst}]
	-v	The height of output picture.[${txtred}Default 20${txtrst}] 
	-E	The type of output figures.[${txtred}Default pdf, accept
		eps/ps, tex (pictex), png, jpeg, tiff, bmp, svg and wmf)${txtrst}]
	-r	The resolution of output picture.[${txtred}Default 300 ppi${txtrst}]
	-F	Font size [${txtred}Default 14${txtrst}]
	-x	The color for representing low value.[${txtred}Default 
		green${txtrst}]
	-y	The color for representing high value.[${txtred}Default
		red${txtrst}]
	-M	The color representing mid-value.
		[${txtred}Default yellow${txtrst}]
	-Z	Use mid-value or not. [${txtred}Default FALSE, which means
		do not use mid-value. ${txtrst}]
	-X	The mid value you want to use.[${txtred}Default median value. A
		number is ok. When -Z is FALSE and -G is TRUE, this value will be 
		used as a separator point. The program will separate data into
		two parts, [minimum, midpoint] and [midpoint, minimum]. Each
		of these parts will be binned to same number of regions.]${txtrst}]
	-s	The smallest value you want to keep, any number smaller will
		be taken as 0.[${bldred}Default -Inf, Optional${txtrst}]  
	-m	The maximum value you want to keep, any number larger willl
		be taken as the given maximum value.
		[${bldred}Default Inf, Optional${txtrst}] 
	-N	Generate NA value.[${bldred}Assign NA to values in data table equal
		to given value to get different color representation.${txtrst}]
	-Y	Color for NA value.
		[${txtred}Default grey${txtrst}]
	-G	Set data breaks.
		<1> represents automatically break data for color view.
		<2> represents quantile data for color view. 
			Default 5 color scale for each quantile.
			Specially when -X is given, it will be used as midpoint to
			get same number of breaks flanking midpoint.
		<3> represents using given data breaks for color view.
	-C	Color list for plot when -G is TRUE.
		[${bldred}Default 'green','yellow','dark red'.
		Accept a list of colors each wrapped by '' and totally wrapped
		by "" ${txtrst}]
	-O	When -G is <3>, using given data points as separtor to
		assign colors. [${bldred}Normally you can
		select a mid-point and give same bins between the minimum and
		midpoint, the midpoint and maximum.
		Here is the format "0,0.2,0.4,0.6,0.8,1,2,4,6,8,10"${txtrst}]
	-e	Execute or not[${bldred}Default TRUE${txtrst}]
	-i	Install the required packages[${bldred}Default FALSE${txtrst}]
EOF
}

file=''
title=''
cluster_rows='TRUE'
cluster_cols='FALSE'
clustering_distance_rows='correlation'
clustering_distance_cols='correlation'
clustering_method='complete'
legend_breaks='NA'
width=''
label=''
logv='FALSE'
kclu='NA'
scale='none'
execute='TRUE'
ist='FALSE'
legend=' '
na_color='grey'
uwid=20
vhig=20
res=300
fontsize=14
ext='pdf'
xcol='green'
ycol='red'
mcol='yellow'
mid_value_use='FALSE'
mid_value='Inf'
xtics='TRUE'
xtics_angle=0
ytics='TRUE'
gradient=1
givenSepartor=''
gradientC="'green','yellow','red'"
generateNA='FALSE'
digits='FALSE'

while getopts "hf:t:a:A:b:H:R:c:D:I:L:d:k:u:v:E:r:F:x:y:M:Z:X:s:m:N:Y:G:C:O:e:i:" OPTION
do
	case $OPTION in
		h)
			echo "Help mesage"
			usage
			exit 1
			;;
		f)
			file=$OPTARG
			;;
		t)
			title=$OPTARG
			;;
		a)
			xtics=$OPTARG
			;;
		A)
			xtics_angle=$OPTARG
			;;
		b)
			ytics=$OPTARG
			;;
		H)
			cluster_cols=$OPTARG
			;;
		R)
			cluster_rows=$OPTARG
			;;
		c)
			clustering_method=$OPTARG
			;;
		D)
			clustering_distance_rows=$OPTARG
			;;
		I)
			clustering_distance_cols=$OPTARG
			;;
		L)
			logv=$OPTARG
			;;
		d)
			scale=$OPTARG
			;;
		k)
			kclu=$OPTARG
			;;
		u)
			uwid=$OPTARG
			;;
		v)
			vhig=$OPTARG
			;;
		E)
			ext=$OPTARG
			;;
		r)
			res=$OPTARG
			;;
		F)
			fontsize=$OPTARG
			;;
		x)
			xcol=$OPTARG
			;;
		y)
			ycol=$OPTARG
			;;
		M)
			mcol=$OPTARG
			;;
		K)
			logv_pos=$OPTARG
			;;
		Z)
			mid_value_use=$OPTARG
			;;
		X)
			mid_value=$OPTARG
			;;
		s)
			small=$OPTARG
			;;
		m)
			maximum=$OPTARG
			;;
		N)
			generateNA=$OPTARG
			;;
		Y)
			na_color=$OPTARG
			;;
		G)
			gradient=$OPTARG
			;;
		C)
			gradientC=$OPTARG
			;;
		O)
			givenSepartor=$OPTARG
			;;
		e)
			execute=$OPTARG
			;;
		i)
			ist=$OPTARG
			;;
		?)
			usage
			echo "Unknown parameters"
			exit 1
			;;
	esac
done

mid=".pheatmap"

if [ -z $file ] ; then
	echo 1>&2 "Please give filename."
	usage
	exit 1
fi


if test "$log" != ''; then
	mid=${mid}".$log"
fi

if test "${scale}" == "TRUE"; then
	mid=${mid}".scale"
fi


cat <<END >${file}${mid}.r

if ($ist){
	install.packages("pheatmap", repo="http://cran.us.r-project.org")
}
library(pheatmap)

if($gradient){
	library(RColorBrewer)
}


data <- read.table(file="$file", sep="\t", header=T, row.names=1,
	check.names=F, quote="", comment="")

if ("${logv}" != "FALSE"){
	data[data==1] <- 1.0001
	data <- ${logv}(data)
}

if ($gradient == 1){
	legend_breaks = NA
} else if ($gradient == 2){
	if (${mid_value} == Inf){
		summary_v <- c(t(data))
		legend_breaks <- unique(c(seq(summary_v[1]*0.95,summary_v[2],length=6),
		  seq(summary_v[2],summary_v[3],length=6),
		  seq(summary_v[3],summary_v[5],length=5),
		  seq(summary_v[5],summary_v[6]*1.05,length=5)))
	} else {
		legend_breaks <- unique(c(seq(summary_v[1]*0.95, ${mid_value},
		 length=10), seq(${mid_value},summary_v[6]*1.05,length=10)))
	}

	if("${digits}" != "FALSE"){
		legend_breaks <- prettyNum(legend_breaks, digits=${digits})
	}
	
	print(col)
	print(legend_breaks)
} else {
	legend_breaks <- c($givenSepartor)
}

pheatmap(data, kmean_k=$kclu, scale="${scale}", border_color=NA,
cluster_rows=${cluster_rows}, cluster_cols=${cluster_cols}, 
breaks=legend_breaks, clustering_method="${clustering_method}",
clustering_distance_rows="${clustering_distance_rows}", 
clustering_distance_cols="${clustering_distance_cols}", 
legend_breaks=legend_breaks, show_rownames=${xtics}, show_colnames=${ytics}, 
main="$title",
fontsize=${fontsize}, filename="${file}${mid}.${ext}", width=${uwid},
height=${vhig})
	

END

if [ "$execute" == "TRUE" ]; then
	Rscript ${file}${mid}.r
if [ "$?" == "0" ]; then /bin/rm -f ${file}${mid}.r; fi
fi

#convert -density 200 -flatten ${file}${mid}.eps ${first}${mid}.png

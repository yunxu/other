#!/usr/bin/perl -w

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use HTML::Form;
use Data::Dumper;
use File::Path qw( mkpath );

my $old_fh = select(STDOUT);
$| = 1;
select($old_fh);

my $debug = 0;

my $clade	= "mammal";
#my $db	= "hg19";
my $db	= "hg19";
my $hgsid = "385043793_F1aK9Gv68F4AcMSJXfZQGj4jzYr3";
my $hgta_compressType =	"none";
my $hgta_group = "regulation";
my $hgta_outputType	= "";
my $hgta_regionType	= "range";
my $org	= "Human";
my $position = "";
# position calculated by liftover tool
if ($db eq "hg18"){
  $position = "chr16:0-500000";
} elsif ($db eq "hg19"){
  $position = "chr16:60000-560000";
}

my $Root = "ENCODE/".$db."/";
if (! -d $Root){
	mkpath $Root or die "can not create $Root dir";
}

my $url = "http://genome.ucsc.edu/cgi-bin/hgTables";

my $ua = new LWP::UserAgent();

# -----------------------------------------------------------
# Find track name
# -----------------------------------------------------------
my $request_track = POST $url, [
	clade	=> $clade,
	db	=> $db,
	hgsid	=> $hgsid,
	hgta_compressType =>	$hgta_compressType,
	hgta_group	=> $hgta_group,
	hgta_regionType	=> $hgta_regionType,
	org	=> $org,
	position	=> $position,
	# hgta_track	=> "wgEncodeGisChiaPet",
	# hgta_table	=> "wgEncodeGisChiaPetK562CtcfInteractionsRep1",
  #	hgta_outputType	=> $hgta_outputType,
	# hgta_doTopSubmit =>	"get output"
];

my $response_track = $ua->request($request_track);

my $form_track = HTML::Form->parse($response_track);
my $input_track = $form_track->find_input("hgta_track");

my $README_track = Dumper $input_track->{"menu"};

open (README, ">$Root"."/README");
  print README $README_track;
close (README);


foreach my $HOption_track (@{$input_track->{"menu"}}){
	my $TrackDir = $Root.$HOption_track->{"value"};
	my $TrackName = $HOption_track->{"value"};

	if (! -d $TrackDir){
		mkpath $TrackDir or die "Failed to create $TrackDir directory";
	}

  # -----------------------------------------------------------
  # Enumerate table name  
  # -----------------------------------------------------------
	my $request_table = POST $url, [
		clade	=> $clade,
		db	=> $db,
		hgsid	=> $hgsid,
		hgta_compressType =>	$hgta_compressType,
		hgta_group	=> $hgta_group,
		hgta_regionType	=> $hgta_regionType,
		org	=> $org,
		position	=> $position,
		hgta_track	=> $TrackName,
		# hgta_table	=> "wgEncodeGisChiaPetK562CtcfSigRep1",
    # hgta_outputType	=> $hgta_outputType,
		# hgta_doTopSubmit =>	"get output",
	];
	my $response_table = $ua->request($request_table);
	my $form_table = HTML::Form->parse($response_table);

	my $input_table = $form_table->find_input("hgta_table");

	my $README_table = Dumper $input_table->{"menu"};
	open (README, ">".$TrackDir."/README");
  	print README $README_table;
	close (README);
	
	print $TrackName."\n";
	foreach my $HOption_table (@{$input_table->{"menu"}}){
		my $Table = $HOption_table->{"value"};

		if ($Table =~ m/GM12878/i || $Table =~ m/K562/i){
			print "\t".$Table."\n";

      # -----------------------------------------------------------
      # Get output type
      # -----------------------------------------------------------
			my $request_outputType = POST $url, [
				clade	=> $clade,
				db	=> $db,
				hgsid	=> $hgsid,
				hgta_compressType =>	$hgta_compressType,
				hgta_group	=> $hgta_group,
				hgta_regionType	=> $hgta_regionType,
				org	=> $org,
				position	=> $position,
				hgta_track	=> $TrackName,
				hgta_table	=> $Table,
        # hgta_outputType	=> $input_hgta_outputType,
        # hgta_doTopSubmit =>	"get output"
			];
			my $response_outputType = $ua->request($request_outputType);


      my $form_outputType = HTML::Form->parse($response_outputType);
      my $input_hgta_outputType = $form_outputType->value("hgta_outputType");

      # Ignore wigData output type 
      if ($input_hgta_outputType eq "wigData"){ next; }
      # print $input_hgta_outputType."\n";
		
      # -----------------------------------------------------------
      # Get result
      # -----------------------------------------------------------
			my $request_result = POST $url, [
				clade	=> $clade,
				db	=> $db,
				hgsid	=> $hgsid,
				hgta_compressType =>	$hgta_compressType,
				hgta_group	=> $hgta_group,
				hgta_regionType	=> $hgta_regionType,
				org	=> $org,
				position	=> $position,
				hgta_track	=> $TrackName,
				hgta_table	=> $Table,
        hgta_outputType	=> $input_hgta_outputType,
        hgta_doTopSubmit =>	"get output"
			];

      my $response_result = $ua->request($request_result);

			my $filename_result = $TrackDir."/".$Table.".txt";
			open (OF, ">$filename_result");
			print OF $response_result->content;
			close (OF);
      if ($debug){ last; }
		}
    if ($debug){ last; }
	}
  if ($debug){ last; }
}





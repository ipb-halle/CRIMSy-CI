#!/usr/bin/perl -w
#
# benchmark performance of bingo vs. pgchem vs. RDKit
#
# presence of RDKit is required
#
# Usage:
#  benchmark [--bingo] [--pgchem]
#  benchmark [--count=NUMBER OF TESTS]
#
#
# Queries
# =======
# Bingo: SELECT COUNT(*) FROM compounds_bingo WHERE mol @ ('SMILES', '')::bingo.sub;
# RDKit: SELECT COUNT(*) FROM compounds_rdkit WHERE mol @> 'SMILES / SMARTS';
# pgchem: SELECT COUNT(*) FROM compounds_pgchem WHERE mol >= 'SMILES / SMARTS';
#
use DBI;

$use_bingo = 0;
$use_pgchem = 0;
$use_rdkit = 0;
$run_init = 0;
$count = 0;

$dbh = DBI->connect("dbi:Pg:dbname=test;host=localhost;port=5432", 
  'test', 'test', {AutoCommit => 1});

for my $arg ( @ARGV ) {
    if ($arg =~ /^--count=[0-9]+/) {
        $run_init = 1;
        $count = (split "=", $arg)[1];
    } elsif ($arg eq "--bingo") {
        $use_bingo = 1;
    } elsif ($arg eq "--pgchem") {
        $use_pgchem = 1;
    } elsif ($arg eq "--rdkit") {
        $use_rdkit = 1;
    } else {
        die "invalid argument: $arg";
    }
}

if ($run_init) {
        print "Initializing\n";
        &initDB($count);
        exit(0);
}


my $sql = "SELECT id, rdkit_id, smiles FROM benchmark WHERE rdkit_count is null";
my @result = $dbh->selectall_array($sql);
foreach my $row ( @result ) {

    print("id: $row->[0] smiles: $row->[2]\n");
    if ($use_bingo) {
        &check_bingo($row->[0], $row->[2]);
    }
    if ($use_pgchem) {
        &check_pgchem($row->[0], $row->[2]);
    }
    if ($use_rdkit) {
        &check_rdkit($row->[0], $row->[2]);
    }
}

$dbh->disconnect();

sub check_bingo() {
        my $id = shift;
        my $smiles = shift;
        my $start_sql = "UPDATE benchmark set bingo_start=now() WHERE id=?";
        my $stop_sql = "UPDATE benchmark set bingo_stop=now() WHERE id=?";
        my $query_sql = "UPDATE benchmark SET ( bingo_count ) = (SELECT count(*) FROM compounds_bingo WHERE mol @ (?, '')::bingo.sub) WHERE id=?";

        $dbh->do($start_sql, undef, ( $id ));

        $dbh->do($query_sql, undef, ( $smiles, $id ));

        $dbh->do($stop_sql, undef, ( $id ));
}

sub check_pgchem() {
        my $id = shift;
        my $smiles = shift;
        my $start_sql = "UPDATE benchmark set pgchem_start=now() WHERE id=?";
        my $stop_sql = "UPDATE benchmark set pgchem_stop=now() WHERE id=?";
        my $query_sql = "UPDATE benchmark SET ( pgchem_count ) = (SELECT count(*) FROM compounds_pgchem WHERE mol >= ?)  WHERE id=?";

        $dbh->do($start_sql, undef, ( $id ));

        $dbh->do($query_sql, undef, ( $smiles, $id ));

        $dbh->do($stop_sql, undef, ( $id ));
}

sub check_rdkit() {
        my $id = shift;
        my $smiles = shift;
        my $start_sql = "UPDATE benchmark set rdkit_start=now() WHERE id=?";
        my $stop_sql = "UPDATE benchmark set rdkit_stop=now() WHERE id=?";
        my $query_sql = "UPDATE benchmark SET ( rdkit_count ) = (SELECT count(*) FROM compounds_rdkit WHERE mol @> ?)  WHERE id=?";

        $dbh->do($start_sql, undef, ( $id ));

        $dbh->do($query_sql, undef, ( $smiles, $id ));

        $dbh->do($stop_sql, undef, ( $id ));
}

#
#=============================================================================
#
# initializes the benchmark table with an approximate (!) number of 
# examples
#
sub initDB() {
    my $count = shift;
    my $sql = "DROP TABLE IF EXISTS benchmark";

    $dbh->do($sql);

    my @result = $dbh->selectrow_arrayref("SELECT MAX(id) FROM compounds_rdkit");
    my $size = $result[0]->[0];

    $sql = "CREATE TABLE benchmark (
        id SERIAL NOT NULL PRIMARY KEY, 
        rdkit_id BIGINT REFERENCES compounds_rdkit(id), 
        smiles TEXT, 
        bingo_count INTEGER,
        bingo_start TIMESTAMP,
        bingo_stop TIMESTAMP,
        pgchem_count INTEGER,
        pgchem_start TIMESTAMP,
        pgchem_stop TIMESTAMP,
        rdkit_count INTEGER, 
        rdkit_start TIMESTAMP, 
        rdkit_stop TIMESTAMP)";

    $dbh->do($sql);

    $sql = "INSERT INTO benchmark (rdkit_id, smiles) SELECT r.id, r.mol FROM compounds_rdkit AS r 
    JOIN (SELECT (random() * ?)::BIGINT AS id FROM generate_series(1,?)) AS s ON r.id = s.id WHERE r.mol IS NOT NULL";
    $dbh->do($sql, undef, ( $size, $count));
}


[![](https://img.shields.io/docker/cloud/build/ipbhalle/ccdbc.svg)](https://hub.docker.com/r/ipbhalle/ccdbc/builds/)

# CRIMSy Container Images

This project provides a collection of container images for use with [CRIMSy](https://github.com/ipb-halle/CRIMSy): 

 * An PostgreSQL 11 image augmented with two extensions for chemical structure handling: ([pgchem::tigress](https://github.com/ergo70/pgchem_tigress) and [RDKit](https://github.com/rdkit/rdkit), formerly published as ccdbc [Combined Chemistry DataBase Cartridges])
 * An Apache HTTP Server image containing a selection of JavaScript libraries for chemical drawing and spectra display

Additionally, this project will provide a few additional images for experimenting:

 * some images are based upon different PostgreSQL releases 
 * some images provide the Bingo database extension 


# Getting started
To set up a fresh database container, run the following command:

    docker run -e POSTGRES_PASSWORD="your-OWN-password" -v /path/to/your/storage:/var/lib/postgresql/data ipbhalle/crimsydb:pg11

You may want to select a different database image (e.g. `ipbhalle/bingo:pg11`). For smaller experiments, you may also want to omit the `-v` option.

A newly set up database requires activation of the database extensions. See the following example commands for reference:

    // pgchem::tigress
    CREATE EXTENSION IF NOT EXISTS "pgchem_tigress";
    CREATE TABLE example_pgchem (
        id SERIAL NOT NULL PRIMARY KEY,
        mol MOLECULE);
    CREATE INDEX i_example_pgchem_mol_idx ON example_pgchem USING gist(mol);
    SELECT * from example_pgchem WHERE mol >= 'CCOCC';

    // RDKit
    CREATE EXTENSION IF NOT EXISTS "rdkit";
    CREATE TABLE example_rdkit (
        id SERIAL NOT NULL PRIMARY KEY,
        mol MOL);
    CREATE INDEX i_example_rdkit_mol_idx ON example_rdkit USING gist(mol);
    SELECT * from example_rdkit WHERE mol @> 'CCOCC';

    // Bingo
    /*
        GRANT USAGE ON SCHEMA bingo TO %ROLE%;
        GRANT SELECT ON bingo.bingo_config TO %ROLE%;
        GRANT SELECT ON bingo.bingo_tau_config TO %ROLE%;
     */
    CREATE TABLE example_bingo (
        id SERIAL NOT NULL PRIMARY KEY,
        mol TEXT);
    CREATE INDEX i_example_bingo_mol_idx ON example_bingo USING bingo_idx (mol bingo.molecule);
    SELECT * from example_bingo WHERE mol @ ('CCOCC', '')::bingo.sub;
    
# More docs

The containers are based on the official Apache httpd and PostgreSQL containers, respectively. For reference see

 * Apache httpd: [https://hub.docker.com/_/httpd](https://hub.docker.com/_/httpd) and [https://github.com/docker-library/docs/blob/master/httpd/README.md](https://github.com/docker-library/docs/blob/master/httpd/README.md)
 * PostgreSQL:  [https://hub.docker.com/_/postgres](https://hub.docker.com/_/postgres) and [https://github.com/docker-library/docs/blob/master/postgres/README.md](https://github.com/docker-library/docs/blob/master/postgres/README.md)
 * pgchem::tigress: [https://github.com/ergo70/pgchem_tigress/](https://github.com/ergo70/pgchem_tigress/)
 * RDKit: [https://www.rdkit.org/docs/Cartridge.html](https://www.rdkit.org/docs/Cartridge.html) and [
 * Bingo: [https://github.com/epam/Indigo](https://github.com/epam/Indigo) and [https://lifescience.opensource.epam.com/bingo/user-manual-postgres.html](https://lifescience.opensource.epam.com/bingo/user-manual-postgres.html)


Have fun!


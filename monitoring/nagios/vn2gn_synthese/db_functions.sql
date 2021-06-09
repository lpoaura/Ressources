/* 
  Two SQL functions that check age of last data by VisioNature sources
*/

CREATE SCHEMA IF NOT EXISTS dbadmin;

DROP FUNCTION IF EXISTS dbadmin.check_vn_updates();

CREATE OR REPLACE FUNCTION dbadmin.check_vn_updates()
    RETURNS TABLE
            (
                result int,
                source varchar
            )
as
$func$
BEGIN
    return QUERY (with t1 as (select max(synthese.meta_create_date) as lastcreate, name_source
                              from gn_synthese.synthese
                                       join gn_synthese.t_sources on synthese.id_source = t_sources.id_source
                              where name_source like 'vn%'
                              group by name_source)
                  select abs(extract(epoch from (now() - lastcreate)) / 3600)::int as age_lastts, name_source as source
                  from t1);
END ;
$func$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS dbadmin.check_synthese_update_by_source(varchar);
CREATE OR REPLACE FUNCTION dbadmin.check_synthese_update_by_source(_source varchar)
    RETURNS TABLE
            (
                result int,
                source varchar
            )
as
$func$
DECLARE
    _check varchar;
BEGIN
    return QUERY (with t1 as (select max(synthese.meta_create_date) as lastcreate, name_source
                              from gn_synthese.synthese
                                       join gn_synthese.t_sources on synthese.id_source = t_sources.id_source
                              where name_source like _source
                              group by name_source)
                  select abs(extract(epoch from (now() - lastcreate)) / 3600)::int as age_lastts, name_source as source
                  from t1);

END ;
$func$ LANGUAGE plpgsql;

/* Tests */

set role nagios;
select *
from dbadmin.check_vn_updates();
select *
from dbadmin.check_synthese_update_by_source('vn07');


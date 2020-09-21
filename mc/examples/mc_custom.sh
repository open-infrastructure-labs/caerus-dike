#!/bin/bash

# We assume that root is above
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$SOURCE/.."

#$ROOT/./run_mc.sh minio custom \
#    --query "SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' " \
#    myminio/sql-test/TotalPopulation.csv


# Region,Country,Item Type,Sales Channel,Order Priority,Order Date,Order ID,Ship Date,Units Sold,Unit Price,Unit Cost,Total Revenue,Total Cost,Total Profit
#$ROOT/run_mc.sh minio custom \
#    --query "SELECT s.Country, s.'Item Type', MAX(s.'Total Profit') FROM s3object AS s WHERE s.Region LIKE 'Europe' AND s.'Unit Price'>50 " \
#    myminio/sql-test/5m-Sales-Records.csv

#Greece Office Supplies 651.21 546536.25 1738700 
$ROOT/run_mc.sh minio custom \
    --query "SELECT s.Country, s.'Item Type', s.'Unit Price', s.'Total Profit' FROM s3object AS s WHERE cast(s.'Total Profit' as int) > 1738000 AND cast(s.'Order ID' as int) = 798693454;" \
    myminio/sql-test/5m-Sales-Records.csv

#$ROOT/run_mc.sh minio custom \
#    --query "SELECT s.Country, s.'Item Type', s.'Unit Price', s.'Total Profit', MAX(cast(s.'Total Profit' as int)) FROM s3object AS s ;" \
#    myminio/sql-test/5m-Sales-Records.csv


#$ROOT/run_mc.sh minio custom  --query "MD5"  myminio/sql-test/TotalPopulation.csv
#$ROOT/run_mc.sh minio custom  --query "SELECT COUNT(*) FROM s3object"  myminio/sql-test/TotalPopulation.csv
#$ROOT/run_mc.sh minio custom  --query "SELECT COUNT1( s.Location) FROM s3object AS s"  myminio/sql-test/TotalPopulation.csv

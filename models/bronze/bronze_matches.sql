SELECT *
FROM {{ source('raw', 'match') }}
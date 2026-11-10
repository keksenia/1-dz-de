{% macro postgres__create_table_as(temporary, relation, sql) -%}
    {%- set distributed_by = config.get('distributed_by') -%}
    {%- set distributed_replicated = config.get('distributed_replicated', false) -%}
    {%- set orientation = config.get('orientation') -%}

    create {% if temporary %}temporary {% endif %}table {{ relation }}
    {%- if orientation %}
    with (appendoptimized = true, orientation = {{ orientation }})
    {%- endif %}
    as (
        {{ sql }}
    )
    {% if distributed_replicated and not temporary -%}
    distributed replicated
    {%- elif distributed_by -%}
    distributed by ({{ distributed_by }})
    {%- else -%}
    distributed randomly
    {%- endif %};
{%- endmacro %}

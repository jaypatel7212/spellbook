{% macro paragraph_referral_rewards(
    blockchain
    ,FeeManager_evt_FeeDistributed
    ,native_currency_contract = var('ETH_ERC20_ADDRESS')
    )
%}

select
    '{{blockchain}}' as blockchain
    ,'paragraph' as project
    ,'v1' as version
    ,evt_block_number as block_number
    ,evt_block_time as block_time
    ,cast(date_trunc('day',evt_block_time) as date) as block_date
    ,cast(date_trunc('month',evt_block_time) as date) as block_month
    ,evt_tx_hash as tx_hash
    ,'NFT' as category
    ,recipient as referrer_address
    ,minter as referee_address
    ,{{native_currency_contract}} as currency_contract
    ,amount as reward_amount_raw
    ,caller as project_contract_address
    ,evt_index as sub_tx_id
    ,tx."from" as tx_from
    ,tx.to as tx_to
from {{FeeManager_evt_FeeDistributed}} e
inner join {{source(blockchain, 'transactions')}} tx
    on evt_block_number = tx.block_number
    and evt_tx_hash = tx.hash
    {% if is_incremental() %}
    and {{incremental_predicate('tx.block_time')}}
    {% endif %}
where
    "feeType" = 'mintReferrer'
{% if is_incremental() %}
    and {{incremental_predicate('evt_block_time')}}
{% endif %}
{% endmacro %}

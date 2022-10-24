<script>
    export let expanded = false;
    function toggle() {
        expanded = !expanded;
    }

    export let section_name;
    export let section_data;
</script>

<div>
    <span on:click={toggle} on:keypress={toggle} class="clickable">
        {#if section_data.size > 0}
            <span class="plus">
                {section_name}: +{section_data.size}
            </span>
        {:else}
            <span class="minus">
                {section_name}: {section_data.size}
            </span>
        {/if}</span
    >
    {#if expanded}
        {#each Object.entries(section_data.names) as [symbol_name, symbol_size]}
            <div>
                {#if symbol_size > 0}
                    <span class="plus">
                        {symbol_name}: +{symbol_size}
                    </span>
                {:else}
                    <span class="minus">
                        {symbol_name}: {symbol_size}
                    </span>
                {/if}
            </div>
        {/each}
    {/if}
</div>

<style>
    div {
        margin-left: 1em;
    }
</style>

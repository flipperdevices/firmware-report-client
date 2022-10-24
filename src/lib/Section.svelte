<script>
    import Icon from "./Icon.svelte";

    export let name;
    export let data;

    export let expanded = false;
    function toggle() {
        expanded = !expanded;
    }
</script>

<div><span on:click={toggle} on:keypress={toggle} class="clickable">
    {#if data.size > 0}
        <Icon icon="file-plus" color="#b9b9b9" />
    {:else}
        <Icon icon="file-minus" color="#b9b9b9" />
    {/if}

    {name}</span>
    {#if data.size > 0}
        <span class="plus">{name} : +{data.size}</span>
    {:else}
        <span class="minus">{name} : {data.size}</span>
    {/if}
</div>
{#if expanded}
    <div class="objects">
        {#each Object.entries(data.objects) as [object_name, object_data]}
            <div>
                <!-- <span>{object_name}</span> -->
                {#if object_data.size > 0}
                    <span class="plus">{object_name} : +{object_data.size}</span
                    >
                {:else}
                    <span class="minus">{object_name} : {object_data.size}</span
                    >
                {/if}
            </div>
            <div class="symbols">
                {#each Object.entries(object_data.symbols) as [symbol_name, symbol_size]}
                    <div>
                        <!-- <span>{object_name}</span> -->
                        {#if object_data.size > 0}
                            <span class="plus">
                                {symbol_name} : +{symbol_size}
                            </span>
                        {:else}
                            <span class="minus">
                                {symbol_name} : {symbol_size}
                            </span>
                        {/if}
                    </div>
                {/each}
            </div>
        {/each}
    </div>
{/if}

<style>
    .objects {
        margin-left: 1em;
    }

    .symbols {
        margin-left: 1em;
    }
</style>

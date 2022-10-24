<script>
    import FileSection from "./FileSection.svelte";
    import Icon from "./Icon.svelte";

    export let filename;
    export let file_data;

    function is_empty(obj) {
        return Object.keys(obj).length === 0;
    }

    export let expanded = false;
    function toggle() {
        expanded = !expanded;
    }
</script>

<div>
    <span on:click={toggle} on:keypress={toggle} class="clickable">
        {#if !is_empty(file_data.next)}
            <Icon icon="folder" color="#b9b9b9" />
        {:else}
            <Icon icon="file-text" color="#b9b9b9" />
        {/if}
        {filename}
    </span>
    <span>
        {#each Object.entries(file_data.sections) as [section_name, section_data]}
            {#if section_data.size > 0}
                <span class="section_name plus"
                    >{section_name}: +{section_data.size}</span
                >
            {:else}
                <span class="section_name minus"
                    >{section_name}: {section_data.size}</span
                >
            {/if}
        {/each}
    </span>

    {#if expanded}
        {#if !is_empty(file_data.next)}
            {#each Object.entries(file_data.next) as [next_filename, next_file_data]}
                <svelte:self
                    filename={next_filename}
                    file_data={next_file_data}
                />
            {/each}
        {:else}
            {#each Object.entries(file_data.sections) as [section_name, section_data]}
                <FileSection {section_name} {section_data} />
            {/each}
        {/if}
    {/if}
</div>

<style>
    div {
        margin-left: 1em;
    }

    .section_name {
        margin-left: 1em;
    }
</style>

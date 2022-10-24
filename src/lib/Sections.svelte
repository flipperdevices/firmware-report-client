<script>
    import Section from "./Section.svelte";

    export let sections;
</script>

<div class="sections">
    {#each Object.entries(sections) as [section_name, section_data]}
        <Section name={section_name} data={section_data} />
    {/each}
</div>

<style>
    .sections {
        text-align: left;
        margin-left: 1em;
    }
</style>

<script>
    import File from "./File.svelte";

    export let files;
</script>

<div>
    {#each Object.entries(files) as [filename, file_data]}
        <File {filename} {file_data} />
    {/each}
</div>

<style>
    div {
        text-align: left;
    }
</style>

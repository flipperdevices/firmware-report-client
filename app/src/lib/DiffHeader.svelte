<script>
    export let data = {
        header: "",
        message: "",
        size: 0,
    };

    export let expanded = false;
    function toggle() {
        expanded = !expanded;
    }
</script>

<div>
    <div>
        {data.header}
        [
        {#if data.size > 0}
            <span class="plus">
                +{data.size}
            </span>
        {:else}
            <span class="minus">
                {data.size}
            </span>
        {/if}
        ]
    </div>
    <div class="diff_message {expanded ? 'clickable-like' : ''}">
        <div
            class="clickable diff_header"
            on:click={toggle}
            on:keypress={toggle}
        >
            <span>
                {data.message.split("\n")[0]}
            </span>
        </div>
        {#if expanded && data.message.split("\n").length > 1}
            {#each data.message.split("\n").slice(1) as line}
                {line}<br />
            {/each}
            <br />
        {/if}
    </div>
</div>

<style>
    .diff_header {
        text-align: center;
    }

    .diff_message {
        text-align: left;
        display: inline-block;
    }
</style>

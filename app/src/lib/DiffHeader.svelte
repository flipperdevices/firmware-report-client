<script>
    export let data = {
        commit_1: "",
        commit_2: "",
        message: "",
    };

    export let expanded = false;
    function toggle() {
        expanded = !expanded;
    }
</script>

<div>
    <div>
        Diff between {data.commit_1}
        and {data.commit_2}
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
        {#if expanded}
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

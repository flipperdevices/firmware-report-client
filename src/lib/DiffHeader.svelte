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
        Diff between {data.commit_1.substring(0, 7)}
        and {data.commit_2.substring(0, 7)}
    </div>
    <div class="diff_message" on:click={toggle} on:keypress={toggle}>
        <span class="clickable">{data.message.split("\n")[0]}</span>
        {#if expanded}
            {#each data.message.split("\n").slice(1) as line}
                {line}<br />
            {/each}
        {/if}
    </div>
</div>

<style>
    .diff_message {
        text-align: left;
        display: inline-block;
    }
</style>

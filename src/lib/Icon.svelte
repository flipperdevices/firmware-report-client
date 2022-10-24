<script>
    export let icon = "";
    export let color = "";
</script>

<span
    class="icon"
    style="background-color: {color}; -webkit-mask-image: url('/icons/{icon}.svg'); mask-image: url('/icons/{icon}.svg');"
/>

<style>
    .icon {
        display: inline-block;
        width: 0.8em;
        height: 0.8em;
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
        -webkit-mask-size: cover;
        mask-size: cover;
        margin-right: 0.1em;
    }
</style>

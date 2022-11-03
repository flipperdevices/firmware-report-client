<script>
    let popup_shown = false;
    const show_popup = () => {
        popup_shown = !popup_shown;
    };
</script>

<div style="position:relative;">
    <div
        class="help-icon"
        on:mouseenter={() => (popup_shown = true)}
        on:mouseleave={() => (popup_shown = false)}
    >
        ?
    </div>
    {#if popup_shown}
        <div class="popup">
            <ul>
                <li>LMB: diff between current and previous commit</li>
                <li>LMB + Q: info about current commit</li>
                <li>LMB + 1: store commit</li>
                <li>LMB + 2: diff between stored and current commit</li>
            </ul>
        </div>
    {/if}
</div>

<style>
    .help-icon {
        cursor: pointer;
        border-radius: 50%;
        border: 1px solid #a9a9a9;
        color: #a9a9a9;
        display: inline-block;
        width: 1.4rem;
        height: 1.4rem;
        position: relative;
    }

    .popup {
        position: absolute;
        top: 1.5rem;
        right: 1.5rem;
        background-color: #00000040;
        border: 1px solid #a9a9a9;
        border-radius: 0.5rem;
        padding: 0.5rem;
        z-index: 1;
        max-width: 400px;
        width: max-content;
        text-align: left;
    }

    ul {
        padding: 0;
        margin: 0;
        padding-left: 1rem;
    }
</style>

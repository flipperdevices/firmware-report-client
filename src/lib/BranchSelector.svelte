<script>
    import { createEventDispatcher } from "svelte";
    import api_get from "./api.js";

    const dispatch = createEventDispatcher();

    let selected = {
        type: "dev",
        release: "",
        release_candidate: "",
        misc: "",
        user: "",
        pull_request: "",
    };

    let branches = null;
    async function fetch_branches() {
        if (branches == null) {
            let json = await api_get("api/v0/branches");
            branches = json;
            selected.user = Object.keys(branches.pull_request_user_branches)[0];
        }
        return branches;
    }

    function handle_submit() {
        let value = "dev";
        if (selected.type != value) {
            value = selected[selected.type];
        }

        dispatch("new_branch", {
            branch_name: value,
        });
    }
</script>

{#await fetch_branches()}
    <p>loading</p>
{:then data}
    <form on:submit|preventDefault={handle_submit}>
        <div>
            <label>
                <input
                    type="radio"
                    bind:group={selected.type}
                    name="selected.branch"
                    value={"dev"}
                    on:change={handle_submit}
                />
                dev:{data.main_branches[0].count}
            </label>
        </div>
        <div>
            <label>
                <input
                    type="radio"
                    bind:group={selected.type}
                    name="selected.branch"
                    value={"release"}
                />
                R
            </label>
            <label>
                <select
                    bind:value={selected.release}
                    on:click={() => (selected.type = "release")}
                    on:change={handle_submit}
                >
                    {#each data.release_branches as value}
                        <option value={value.branch_name}>
                            {value.branch_name}
                        </option>
                    {/each}
                </select>
            </label>
        </div>
        <div>
            <label>
                <input
                    type="radio"
                    bind:group={selected.type}
                    name="selected.branch"
                    value={"release_candidate"}
                />
                RC
            </label>
            <label>
                <select
                    bind:value={selected.release_candidate}
                    on:click={() => (selected.type = "release_candidate")}
                    on:change={handle_submit}
                >
                    {#each data.release_candidate_branches as value}
                        <option value={value.branch_name}>
                            {value.branch_name}
                        </option>
                    {/each}
                </select>
            </label>
        </div>
        <div>
            <label>
                <input
                    type="radio"
                    bind:group={selected.type}
                    name="selected.branch"
                    value={"misc"}
                />
                ?
            </label>
            <label>
                <select
                    bind:value={selected.misc}
                    on:click={() => (selected.type = "misc")}
                    on:change={handle_submit}
                >
                    {#each data.misc_branches as value}
                        <option value={value.branch_name}>
                            {value.branch_name}:{value.count}
                        </option>
                    {/each}
                </select>
            </label>
        </div>
        <div>
            <label>
                <input
                    type="radio"
                    bind:group={selected.type}
                    name="selected.branch"
                    value={"pull_request"}
                />
                PR
            </label>

            <label>
                <select
                    bind:value={selected.user}
                    on:click={() => (selected.type = "pull_request")}
                >
                    {#each Object.entries(data.pull_request_user_branches) as [user, user_data]}
                        <option value={user}>
                            {user}:{user_data.count}
                        </option>
                    {/each}
                </select>
            </label>
            <label>
                <select
                    bind:value={selected.pull_request}
                    on:click={() => (selected.type = "pull_request")}
                    on:change={handle_submit}
                >
                    {#each data.pull_request_user_branches[selected.user].branches as value}
                        <option value={value.branch_name}>
                            {value.branch_name.replace(
                                selected.user + "/",
                                ""
                            )}:{value.count}
                        </option>
                    {/each}
                </select>
            </label>
        </div>
    </form>
{:catch error}
    <p style="color: red">{error.message}</p>
{/await}

<style>
    select {
        max-width: 100px;
    }

    form {
        display: flex;
        flex-direction: row;
        justify-content: space-around;
    }

    form div {
        display: inline-block;
    }
</style>

<script>
    import { Line } from "svelte-chartjs";
    import "chart.js/auto";
    import api_get from "./lib/api.js";
    import BranchSelector from "./lib/BranchSelector.svelte";
    import Files from "./lib/Files.svelte";
    import Sections from "./lib/Sections.svelte";
    import DiffHeader from "./lib/DiffHeader.svelte";

    const total_flash_size = 1024 * 1024;

    let dev_data;
    const chart_data = {
        labels: [],
        datasets: [
            {
                label: "Used Flash",
                data: [],
                backgroundColor: "rgba(255, 99, 132, 0.2)",
                borderColor: "rgba(255, 99, 132, 1)",
                borderWidth: 1,
            },
        ],
    };

    function get_diff(i, field, revert = false) {
        let string = "";
        let diff = 0;

        if (revert) {
            diff = dev_data[i - 1][field] - dev_data[i][field];
        } else {
            diff = dev_data[i][field] - dev_data[i - 1][field];
        }

        if (diff > 0) {
            string += "+";
        }
        string += diff;

        return string;
    }

    function get_commit_message(i) {
        let message = dev_data[i].commit_msg;
        message = message.replace(/^\'+/, "").replace(/\'+$/, "");
        message = message.replaceAll("'\"'\"'", '"');
        return message;
    }

    const commit_info = (i) => {
        let string = "";

        if (i > 0) {
            string += "used: " + get_diff(i, "free_flash_size", true) + "\r\n";
            string += ".bss: " + get_diff(i, "bss_size") + "\r\n";
            string += ".data: " + get_diff(i, "data_size") + "\r\n";
            string += ".rodata: " + get_diff(i, "rodata_size") + "\r\n";
            string += ".text: " + get_diff(i, "text_size") + "\r\n";
        }

        string += "-------------------------------------" + "\r\n";
        string += "Commit: " + dev_data[i].commit.substring(0, 7) + "\r\n";
        string += "-------------------------------------" + "\r\n";
        string += get_commit_message(i);
        return string;
    };

    let show_diff = false;
    let diff_data = { files: {}, sections: {} };
    let diff_header_data = {
        commit_1: "",
        commit_2: "",
        message: "",
    };

    async function fetch_diff_data(branch_id_1, branch_id_2) {
        show_diff = true;
        diff_data = await api_get(
            "api/v0/commit_diff_data?branch_ids=" +
                branch_id_1 +
                "," +
                branch_id_2
        );

        console.log(diff_data);
        return diff_data;
    }

    const tooltip_footer = (item) => {
        let i = item[0].dataIndex;
        let string = commit_info(i);
        return string;
    };

    const chart_options = {
        scales: {
            x: {
                display: false,
            },
            y: {
                display: true,
            },
        },
        responsive: true,
        plugins: {
            tooltip: {
                callbacks: {
                    footer: tooltip_footer,
                },
            },
        },
        elements: {
            point: {
                hoverRadius: 15,
            },
        },
        animation: {
            duration: 500,
        },
        onClick: (event, item) => {
            if (item.length > 0) {
                let i = item[0].index;
                if (i > 0) {
                    let id_current = dev_data[i].id;
                    let id_previous = dev_data[i - 1].id;
                    console.log(id_current, id_previous);

                    diff_header_data.commit_1 = dev_data[i].commit;
                    diff_header_data.commit_2 = dev_data[i - 1].commit;
                    diff_header_data.message = get_commit_message(i);
                    fetch_diff_data(id_current, id_previous);
                }
                console.log(commit_info(i));
            }
        },
    };

    async function fetch_dev_data(branch_name) {
        dev_data = await api_get("api/v0/branch?branch_name=" + branch_name);

        let labels = [];
        let data = [];
        for (let i = 0; i < dev_data.length; i++) {
            labels.push(dev_data[i].datetime);
            data.push(total_flash_size - dev_data[i].free_flash_size);
        }

        chart_data.labels = labels;
        chart_data.datasets[0].data = data;
        return dev_data;
    }

    let branch_name = "dev";
    function new_branch_selected(event) {
        branch_name = event.detail.branch_name;
        fetch_dev_data(branch_name);
    }
    fetch_dev_data(branch_name);
</script>

<main>
    <BranchSelector on:new_branch={new_branch_selected} />
    <h1>{branch_name}</h1>
    <Line data={chart_data} options={chart_options} />
    {#if show_diff}
        <DiffHeader data={diff_header_data} />
        <Files files={diff_data.files} />
        <Sections sections={diff_data.sections} />
    {/if}
</main>

<style>
</style>

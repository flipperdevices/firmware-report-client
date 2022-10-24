<script>
    import { Line } from "svelte-chartjs";
    import {
        Chart as ChartJS,
        Title,
        Tooltip,
        Legend,
        LineElement,
        LinearScale,
        PointElement,
        CategoryScale,
    } from "chart.js";

    ChartJS.register(
        Title,
        Tooltip,
        Legend,
        LineElement,
        LinearScale,
        PointElement,
        CategoryScale
    );

    import api_get from "./lib/api.js";
    import BranchSelector from "./lib/BranchSelector.svelte";
    import Files from "./lib/Files.svelte";
    import Sections from "./lib/Sections.svelte";
    import DiffHeader from "./lib/DiffHeader.svelte";

    const total_flash_size = 1024 * 1024;

    let branch_data;
    let chart;
    let show_diff = false;
    let diff_data = { files: {}, sections: {} };
    let diff_header_data = {
        commit_1: "",
        commit_2: "",
        message: "",
        size: 0,
    };

    let branch_name = "";
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has("branch")) {
        branch_name = urlParams.get("branch");
    } else {
        branch_name = "dev";
    }

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
            diff = branch_data[i - 1][field] - branch_data[i][field];
        } else {
            diff = branch_data[i][field] - branch_data[i - 1][field];
        }

        if (diff > 0) {
            string += "+";
        }
        string += diff;

        return string;
    }

    function get_commit_message(i) {
        let message = branch_data[i].commit_msg;
        message = message.replace(/^\'+/, "").replace(/\'+$/, "");
        message = message.replaceAll("'\"'\"'", '"');
        return message;
    }

    function get_commit_id(i) {
        return (
            branch_data[i].branch_name +
            ":" +
            branch_data[i].commit.substring(0, 7)
        );
    }

    const get_commit_info = (i) => {
        let string = "";

        if (i > 0) {
            string += "used: " + get_diff(i, "free_flash_size", true) + "\r\n";
            string += ".bss: " + get_diff(i, "bss_size") + "\r\n";
            string += ".data: " + get_diff(i, "data_size") + "\r\n";
            string += ".rodata: " + get_diff(i, "rodata_size") + "\r\n";
            string += ".text: " + get_diff(i, "text_size") + "\r\n";
        }

        string += "-------------------------------------" + "\r\n";
        string += "Commit: " + get_commit_id(i) + "\r\n";
        string += "-------------------------------------" + "\r\n";

        let message = get_commit_message(i);
        message = message.trim().split("\n")[0];
        string += message;

        return string;
    };

    const tooltip_footer = (item) => {
        let i = item[0].dataIndex;
        let string = get_commit_info(i);
        return string;
    };

    const chart_on_click = (event, item) => {
        if (item.length > 0) {
            let i = item[0].index;
            if (i > 0) {
                let id_current = branch_data[i].id;
                let id_previous = branch_data[i - 1].id;
                console.log(id_current, id_previous);

                diff_header_data.commit_1 = get_commit_id(i);
                diff_header_data.commit_2 = get_commit_id(i - 1);
                diff_header_data.message = get_commit_message(i);
                diff_header_data.size =
                    branch_data[i - 1].free_flash_size -
                    branch_data[i].free_flash_size;

                fetch_diff_data(id_current, id_previous);

                chart_clear_style();
                chart_mark_main_point(i);
                chart_mark_secondary_point(i - 1);

                chart.update();
            }
        }
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
        onClick: chart_on_click,
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

    function chart_clear_style() {
        let dataset = chart_data.datasets[0];
        let data_length = dataset.data.length;
        dataset.pointBackgroundColor = Array(data_length).fill("#ff638433");
        dataset.pointRadius = Array(data_length).fill(3);
    }

    function chart_mark_main_point(i) {
        let dataset = chart_data.datasets[0];
        dataset.pointBackgroundColor[i] = "#ff6384cc";
        dataset.pointRadius[i] = 6;
    }

    function chart_mark_secondary_point(i) {
        let dataset = chart_data.datasets[0];
        dataset.pointBackgroundColor[i] = "#ff6384cc";
    }

    async function fetch_branch_data() {
        branch_data = await api_get("api/v0/branch?branch_name=" + branch_name);

        let labels = [];
        let data = [];

        for (let i = 0; i < branch_data.length; i++) {
            labels.push(branch_data[i].datetime);
            data.push(total_flash_size - branch_data[i].free_flash_size);
        }

        chart_data.labels = labels;
        chart_data.datasets[0].data = data;
        chart_clear_style();
        return branch_data;
    }

    function new_branch_selected(event) {
        branch_name = event.detail.branch_name;
        fetch_branch_data();
    }

    fetch_branch_data();
</script>

<main>
    <BranchSelector on:new_branch={new_branch_selected} branch_name />
    <h2>
        {branch_name === "dev"
            ? "dev branch"
            : '"dev" vs "' + branch_name + '"'}
    </h2>
    <Line data={chart_data} options={chart_options} bind:chart />
    {#if show_diff}
        <DiffHeader data={diff_header_data} />
        <div>-=-=- Files -=-=-</div>
        <Files files={diff_data.files} />
        <div>-=-=- Sections -=-=-</div>
        <Sections sections={diff_data.sections} />
    {/if}
</main>

<style>
</style>

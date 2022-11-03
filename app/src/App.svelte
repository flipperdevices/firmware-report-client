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
    import Loader from "./lib/Loader.svelte";
    import Help from "./lib/Help.svelte";
    import { onMount } from "svelte";

    const total_flash_size = 1024 * 1024;

    let branch_data;
    let chart;
    let info_is_empty = true;
    let info_is_loading = false;
    let info_data = { files: {}, sections: {} };
    let info_header_data = {
        header: "",
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

    let helded_keys = new Set();
    onMount(() => {
        window.addEventListener("keydown", (e) => {
            helded_keys.add(e.key.toUpperCase());
        });

        window.addEventListener("keyup", (e) => {
            helded_keys.delete(e.key.toUpperCase());
        });
    });

    function is_key_held(key) {
        console.log(helded_keys);
        return helded_keys.has(key);
    }

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
            string += `used: ${get_diff(i, "free_flash_size", true)}\r\n`;
            string += `.bss: ${get_diff(i, "bss_size")}\r\n`;
            string += `.data: ${get_diff(i, "data_size")}\r\n`;
            string += `.rodata: ${get_diff(i, "rodata_size")}\r\n`;
            string += `.text: ${get_diff(i, "text_size")}\r\n`;
        }

        string += "-------------------------------------\r\n";
        string += `Commit: ${get_commit_id(i)}\r\n`;
        string += "-------------------------------------\r\n";

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

    let line_data = {
        from: 0,
        to: 0,
        enabled: false,
    };

    const line_plugin = {
        afterDraw: (chart) => {
            if (!line_data.enabled) return;

            const ctx = chart.ctx;
            ctx.save();

            const dataset = chart.data.datasets[0];
            const scale_x = chart.scales["x"] || chart.scales[dataset.xAxisID];
            const scale_y = chart.scales["y"] || chart.scales[dataset.yAxisID];

            const x_from = scale_x.getPixelForValue(line_data.from);
            const x_to = scale_x.getPixelForValue(line_data.to);

            const y_from = scale_y.getPixelForValue(
                dataset.data[line_data.from]
            );
            const y_to = scale_y.getPixelForValue(dataset.data[line_data.to]);

            console.log(x_from, x_to, y_from, y_to);

            ctx.beginPath();
            ctx.moveTo(x_from, y_from);
            ctx.lineTo(x_to, y_to);
            ctx.lineWidth = 2;
            ctx.strokeStyle = "rgba(255, 255, 255, 0.2)";
            ctx.stroke();

            let angle = Math.atan2(y_to - y_from, x_to - x_from);
            let head_length = 10;

            //starting a new path from the head of the arrow to one of the sides of the point
            ctx.beginPath();
            ctx.moveTo(x_to, y_to);
            ctx.lineTo(
                x_to - head_length * Math.cos(angle - Math.PI / 7),
                y_to - head_length * Math.sin(angle - Math.PI / 7)
            );

            //path from the side point of the arrow, to the other side point
            ctx.lineTo(
                x_to - head_length * Math.cos(angle + Math.PI / 7),
                y_to - head_length * Math.sin(angle + Math.PI / 7)
            );

            //path from the side point back to the tip of the arrow, and then again to the opposite side point
            ctx.lineTo(x_to, y_to);
            ctx.lineTo(
                x_to - head_length * Math.cos(angle - Math.PI / 7),
                y_to - head_length * Math.sin(angle - Math.PI / 7)
            );

            //draws the paths created above
            ctx.strokeStyle = "rgba(255, 255, 255, 0.2)";
            ctx.lineWidth = 2;
            ctx.stroke();
            ctx.fillStyle = "rgba(255, 255, 255, 0.2)";
            ctx.fill();

            ctx.restore();
        },
    };

    const chart_plugins = [line_plugin];

    const chart_mark_two_points = (main_id, secondary_id) => {
        chart_clear_style();
        chart_mark_main_point(main_id);
        chart_mark_secondary_point(secondary_id);
        chart.update();

        line_data.from = main_id;
        line_data.to = secondary_id;
        line_data.enabled = true;
    };

    const chart_mark_one_point = (main_id) => {
        chart_clear_style();
        chart_mark_main_point(main_id, 8);
        chart.update();
        line_data.enabled = false;
    };

    const load_info = (i) => {
        let commit = get_commit_id(i);

        info_header_data.header = `Info about ${commit}`;
        info_header_data.message = get_commit_message(i);
        info_header_data.size =
            total_flash_size - branch_data[i].free_flash_size;

        fetch_brief_data(branch_data[i].id);
        chart_mark_one_point(i);
    };

    const load_diff = (current, previous) => {
        let commit_1 = get_commit_id(current);
        let commit_2 = get_commit_id(previous);

        info_header_data.header = `Diff between ${commit_1} and ${commit_2}`;
        info_header_data.message = get_commit_message(current);
        info_header_data.size =
            branch_data[previous].free_flash_size -
            branch_data[current].free_flash_size;

        fetch_diff_data(branch_data[current].id, branch_data[previous].id);
        chart_mark_two_points(current, previous);
    };

    const load_simple_diff = (current) => {
        if (current > 0) {
            load_diff(current, current - 1);
        }
    };

    let click_id_1 = 0;
    const chart_on_click = (event, item) => {
        if (item.length > 0) {
            let i = item[0].index;
            console.log(i);

            if (is_key_held("Q")) {
                load_info(i);
            } else if (is_key_held("1")) {
                click_id_1 = i;
                chart_mark_one_point(i);
            } else if (is_key_held("2")) {
                load_diff(click_id_1, i);
            } else {
                load_simple_diff(i);
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
        info_is_empty = false;
        info_is_loading = true;
        info_data = await api_get(
            "api/v0/commit_diff_data?branch_ids=" +
                branch_id_1 +
                "," +
                branch_id_2
        );
        info_is_loading = false;

        return info_data;
    }

    async function fetch_brief_data(branch_id) {
        info_is_empty = false;
        info_is_loading = true;
        info_data = await api_get(
            "api/v0/commit_brief_data?branch_id=" + branch_id
        );
        info_is_loading = false;

        return info_data;
    }

    function chart_clear_style() {
        let dataset = chart_data.datasets[0];
        let data_length = dataset.data.length;
        dataset.pointBackgroundColor = Array(data_length).fill("#ff638433");
        dataset.pointRadius = Array(data_length).fill(3);
    }

    function chart_mark_main_point(i, size = 6) {
        let dataset = chart_data.datasets[0];
        dataset.pointBackgroundColor[i] = "#ff6384cc";
        dataset.pointRadius[i] = size;
    }

    function chart_mark_secondary_point(i) {
        let dataset = chart_data.datasets[0];
        dataset.pointBackgroundColor[i] = "#ff6384cc";
    }

    async function fetch_branch_data() {
        line_data.enabled = false;

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

        if (branch_name != "dev") {
            load_simple_diff(1);
        }
        return branch_data;
    }

    function new_branch_selected(event) {
        branch_name = event.detail.branch_name;
        fetch_branch_data();
    }

    fetch_branch_data();
</script>

<main>
    <div class="header">
        <div class="header_item_0">
            <BranchSelector on:new_branch={new_branch_selected} branch_name />
        </div>
        <Help />
    </div>
    <h2>
        {branch_name === "dev"
            ? "dev branch"
            : '"dev" vs "' + branch_name + '"'}
    </h2>
    <Line
        data={chart_data}
        options={chart_options}
        plugins={chart_plugins}
        bind:chart
    />
    <div class="data-section">
        {#if info_is_loading}
            <Loader />
        {/if}
        {#if !info_is_empty}
            <DiffHeader data={info_header_data} />
            <div>-=-=- Files -=-=-</div>
            <Files files={info_data.files} />
            <div>-=-=- Sections -=-=-</div>
            <Sections sections={info_data.sections} />
        {/if}
    </div>
</main>

<style>
    .data-section {
        position: relative;
    }

    main {
        padding: 2rem;
    }

    .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .header_item_0 {
        flex-grow: 1;
    }
</style>
